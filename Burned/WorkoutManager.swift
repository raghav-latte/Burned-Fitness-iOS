//
//  WorkoutManager.swift
//  Burned
//
//  Created by Raghav Sethi on 04/10/25.
//

import Foundation
import HealthKit
import os
import SwiftUI

@MainActor
@available(iOS 26.0, *)
class WorkoutManager: NSObject, ObservableObject {
    
    struct SessionSateChange {
        let newState: HKWorkoutSessionState
        let date: Date
    }
    
    @Published private(set) var state: HKWorkoutSessionState = .notStarted
    
    @Published var workoutConfiguration: HKWorkoutConfiguration?
    var selectedWorkout: HKWorkoutConfiguration? {
        didSet {
            guard let selectedWorkout else { return }
            Task {
                do {
                    workoutConfiguration = selectedWorkout
                    try await prepareWorkout()
                    metrics.supportsDistance = selectedWorkout.supportsDistance
                    metrics.supportsSpeed = selectedWorkout.supportsSpeed
                } catch {
                    print("Failed to start workout \(error))")
                    state = .notStarted
                }
            }
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    @available(iOS 26.0, *)
    var builder: HKLiveWorkoutBuilder?
    var isLiveActivityActive: Bool = false
    var timer: Timer? = nil
    var printTimer: Timer? = nil
    
    let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    /**
     Creates an asynchronous stream that buffers a single newest element
     and the stream's continuation to yield new elements synchronously to the stream.
     The Swift actors don't handle tasks in a first-in-first-out manner.
     Use `AsyncStream` to ensure that the app presents the latest state.
     */
    let asynStreamTuple = AsyncStream.makeStream(of: SessionSateChange.self, bufferingPolicy: .bufferingNewest(1))
    
    /**
     `WorkoutManager` is a singleton.
     */
    static let shared = WorkoutManager()
    
    /**
     Kick off a task to consume the asynchronous stream. The next value in the stream can't start processing
     until `await consumeSessionStateChange(value)` returns and the loop enters the next iteration, which serializes the asynchronous operations.
     */
    override init() {
        super.init()
        Task {
            for await value in asynStreamTuple.stream {
                await consumeSessionStateChange(value)
            }
        }
    }
    
    func setWorkoutConfiguration(activityType: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = location
        
        selectedWorkout = configuration
    }

    func prepareWorkout() async throws {
        guard let configuration = workoutConfiguration else { return }
        
        state = .prepared
        
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session?.prepare()
    }
    
    func startWorkout() {
        Task {
            do {
                // Start the workout session and begin data collection.
                let startDate = Date()
                session?.startActivity(with: startDate)
                state = .running
                try await builder?.beginCollection(at: startDate)
                
                LiveActivityManager.shared.startLiveActivity(symbol: workoutConfiguration?.activityType.symbol ?? "exclamationmark.questionmark")
                startWorkoutTimer()
                startPrintTimer()
            } catch {
                print("Failed to start workout \(error))")
                state = .notStarted
            }
        }
    }
    
    // Recover the workout for the session.
    func recoverWorkout(recoveredSession: HKWorkoutSession) {
        state = .running
        session = recoveredSession
        builder = recoveredSession.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        workoutConfiguration = recoveredSession.workoutConfiguration
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: recoveredSession.workoutConfiguration)
        
        LiveActivityManager.shared.startLiveActivity(symbol: workoutConfiguration?.activityType.symbol ?? "exclamationmark.questionmark")
        startWorkoutTimer()
        startPrintTimer()
    }

    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the HealthKit store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the HealthKit store.
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.activitySummaryType(),
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.heartRate),
            HKQuantityType(.distanceRowing),
            HKQuantityType(.rowingSpeed),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceWalkingRunning),
            HKCharacteristicType(.activityMoveMode)
        ]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            } catch {
                print("Failed to request authorization: \(error)")
            }
        }
    }

    // MARK: - State Control

    func pause() {
        session?.pause()
        stopTimer()
        stopPrintTimer()
    }

    func resume() {
        session?.resume()
        startWorkoutTimer()
        startPrintTimer()
    }

    func togglePause() {
        switch state {
        case .running:
            pause()
        case .paused:
            resume()
        default:
            print("togglePause() called when workout isn't running or paused")
        }
    }

    func endWorkout() {
        state = .stopped
        session?.stopActivity(with: .now)
        stopTimer()
        stopPrintTimer()
    }

    // MARK: - Workout Metrics
    @Published var metrics: MetricsModel = MetricsModel(elapsedTime: 0)

    @Published var workout: HKWorkout?

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        print("updated statistics=\(statistics)")
        
        guard let activityType = session?.activityType else {
            print("activityType is nil when processing statistics")
            return
        }

        if WorkoutTypes.distanceQuantityType(for: activityType) == statistics.quantityType {
            let meterUnit = HKUnit.meter()
            self.metrics.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit)
            return
        }
            
        if WorkoutTypes.speedQuantityType(for: activityType) == statistics.quantityType {
            let speedUnit = HKUnit.meter().unitDivided(by: HKUnit.second())
            self.metrics.speed = statistics.mostRecentQuantity()?.doubleValue(for: speedUnit)
            return
        }
        
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            self.metrics.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            let energyUnit = HKUnit.kilocalorie()
            self.metrics.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit)
        default:
            print("unhandled quantityType=\(statistics.quantityType) when processing statistics")
            return
        }
    }

    func resetWorkout() {
        print("reset workout data model")
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        
        metrics = MetricsModel(elapsedTime: 0)
        
        stopTimer()
        stopPrintTimer()
        
        state = .notStarted
    }
    
    private func consumeSessionStateChange(_ change: SessionSateChange) async {
        guard change.newState == .stopped, let builder else { return }
        
        let finishedWorkout: HKWorkout?
        do {
            try await builder.endCollection(at: change.date)
            finishedWorkout = try await builder.finishWorkout()
            self.metrics.elapsedTime = finishedWorkout?.duration ?? 0
            LiveActivityManager.shared.endLiveActivity()
            session?.end()
        } catch {
            print("Error finishing workout: \(error)")
            return
        }
        workout = finishedWorkout
        state = .ended
    }
    
    // Starts a timer for the ongoing `workoutManager` session.
    func startWorkoutTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task {
                await MainActor.run {
                    self.metrics.elapsedTime = self.builder?.elapsedTime ?? 0
                    LiveActivityManager.shared.updateLiveActivity(metrics: self.metrics)
                }
            }
        }
    }
    
    func startPrintTimer() {
        printTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            Task {
                await MainActor.run {
                    self.printWorkoutMetrics()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func stopPrintTimer() {
        printTimer?.invalidate()
        printTimer = nil
    }
    
    func printWorkoutMetrics() {
        let workoutType = workoutConfiguration?.activityType.name ?? "Unknown"
        let elapsedTime = formatter.string(from: TimeInterval(metrics.elapsedTime)) ?? "00:00"
        
        print("🏃‍♂️ === WORKOUT METRICS ===")
        print("📱 Workout Type: \(workoutType)")
        print("⏱️ Elapsed Time: \(elapsedTime)")
        
        if let heartRate = metrics.heartRate {
            print("❤️ Heart Rate: \(String(format: "%.0f", heartRate)) bpm")
        }
        
        if let activeEnergy = metrics.activeEnergy {
            print("🔥 Active Energy: \(String(format: "%.0f", activeEnergy)) cal")
        }
        
        if let distance = metrics.distance {
            let distanceInKm = distance / 1000
            print("📏 Distance: \(String(format: "%.2f", distanceInKm)) km")
        }
        
        if let speed = metrics.speed {
            let speedInKmH = speed * 3.6
            print("⚡ Speed: \(String(format: "%.1f", speedInKmH)) km/h")
        }
        
        print("🏁 =======================")
    }
}

// MARK: - HKWorkoutSessionDelegate
@available(iOS 26.0, *)
extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        Task { @MainActor in
            switch toState {
            case .running:
                self.state = .running
            case .paused:
                self.state = .paused
            default:
                // Fill this out as needed.
                break
            }
        }
        
        /**
         Yield the new state change to the asynchronous stream synchronously.
         `asynStreamTuple` is a constant, so it's nonisolated.
         */
        let sessionStateChange = SessionSateChange(newState: toState, date: date)
        asynStreamTuple.continuation.yield(sessionStateChange)
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session did fail with error=\(error)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
@available(iOS 26.0, *)
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        guard let event = workoutBuilder.workoutEvents.last else {
            return
        }
        print("workout builder did collect event=\(event)")
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Task { @MainActor in
            for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType else { return }
                
                let statistics = workoutBuilder.statistics(for: quantityType)
                
                // Update the published values.
                updateForStatistics(statistics)
            }
        }
    }
    
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didEnd workoutActivity: HKWorkoutActivity) {
        print("workout builder did end workout_activity=\(workoutActivity)")
    }
}