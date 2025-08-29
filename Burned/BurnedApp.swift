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
                .presentPaywallIfNeeded { customerInfo in
                    // Returning `true` will present the paywall - show if NOT subscribed
                    return !customerInfo.entitlements.active.keys.contains("premium")
                } purchaseCompleted: { customerInfo in
                    print("Purchase completed: \(customerInfo.entitlements)")
                } restoreCompleted: { customerInfo in
                    // Paywall will be dismissed automatically if "pro" is now active.
                    print("Purchases restored: \(customerInfo.entitlements)")
                }
                 .onAppear {
                    // Initialize RevenueCat first
  
                    // Initialize OneSignal
                    OneSignalManager.shared.initialize()
                    
                    // Keep local notifications as backup
                    NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleDailyNoWorkoutRoast()
                    NotificationManager.shared.scheduleBackgroundWorkoutCheck()
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
