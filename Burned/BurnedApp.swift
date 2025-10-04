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
    @State private var showSplash = true
    
    init() {
        registerBackgroundTasks()
    }
 
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(showSplash: $showSplash)
            } else {
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
                            
                            // Setup background workout monitoring
                            healthKitManager.setupBackgroundWorkoutMonitoring()
                        }
                        
                        // Log initial memory usage
                        print("📊 App startup memory logging:")
                        ElevenLabsManager.shared.logMemoryAndCacheStatus()
                    }
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
        
        // Check for new workouts immediately without delay
        healthKitManager.checkForNewWorkoutAndNotify()
        
        // Complete task immediately for faster response
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleNextBackgroundCheck() {
        let request = BGAppRefreshTaskRequest(identifier: "com.niyat.Burned.workout-check")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60 * 60) // 2 hours (more frequent)
        
        try? BGTaskScheduler.shared.submit(request)
    }
}
