//
//  BurnedApp.swift
//  Burned
//
//  Created by Raghav Sethi on 11/08/25.
//

import SwiftUI
import BackgroundTasks
import RevenueCat
import RevenueCatUI

@main
struct BurnedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var characterViewModel = CharacterViewModel()
 
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .environmentObject(characterViewModel)
               
                 .onAppear {
                    // Initialize RevenueCat first
  
                    // Initialize OneSignal
                    OneSignalManager.shared.initialize()
                    
                    // Only request permissions if onboarding is complete
                    if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                        NotificationManager.shared.requestPermission()
                        NotificationManager.shared.scheduleDailyNoWorkoutRoast()
                        NotificationManager.shared.scheduleBackgroundWorkoutCheck()
                    }
                    
                    registerBackgroundTasks()
                    
                    // Log initial memory usage
                    print("📊 App startup memory logging:")
                    ElevenLabsManager.shared.logMemoryAndCacheStatus()
                }
        }
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.niyat.Burned.workout-check", using: nil) { task in
            handleWorkoutCheck(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleWorkoutCheck(task: BGAppRefreshTask) {
        scheduleNextBackgroundCheck()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        healthKitManager.checkForNewWorkoutAndNotify()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleNextBackgroundCheck() {
        let request = BGAppRefreshTaskRequest(identifier: "com.niyat.Burned.workout-check")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 60 * 60) // 4 hours
        
        try? BGTaskScheduler.shared.submit(request)
    }
}
