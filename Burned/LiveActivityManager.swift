//
//  LiveActivityManager.swift
//  Burned
//
//  Created by Raghav Sethi on 04/10/25.
//

import Foundation
import ActivityKit

@MainActor
@available(iOS 26.0, *)
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    private init() {}
    
    func startLiveActivity(symbol: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        // For now, we'll just log that Live Activity would start
        // In a full implementation, this would create the actual Live Activity
        print("🎯 Starting Live Activity with symbol: \(symbol)")
        
        // Set the live activity flag in WorkoutManager
        WorkoutManager.shared.isLiveActivityActive = true
    }
    
    func updateLiveActivity(metrics: MetricsModel) {
        // For now, we'll just log the update
        // In a full implementation, this would update the actual Live Activity
        if WorkoutManager.shared.isLiveActivityActive {
            print("🔄 Updating Live Activity - Time: \(metrics.getFormattedTime()), HR: \(metrics.getHeartRate()), Distance: \(metrics.getDistance())")
        }
    }
    
    func endLiveActivity() {
        // For now, we'll just log the end
        // In a full implementation, this would end the actual Live Activity
        if WorkoutManager.shared.isLiveActivityActive {
            print("🏁 Ending Live Activity")
            WorkoutManager.shared.isLiveActivityActive = false
        }
    }
}