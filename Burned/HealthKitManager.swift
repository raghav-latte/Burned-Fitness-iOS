import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var stepCount: Int = 0
    @Published var heartRate: Double = 0
    @Published var sleepHours: Double = 0
    @Published var dailyCalories: Double = 0
    @Published var exerciseMinutes: Double = 0
    @Published var latestWorkout: WorkoutData?
    @Published var workoutHistory: [WorkoutHistoryItem] = []
    
    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    private let workoutType = HKObjectType.workoutType()
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            stepCountType,
            heartRateType,
            sleepType,
            workoutType,
            distanceType,
            caloriesType,
            exerciseTimeType
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            stepCountType,
            caloriesType,
            workoutType
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchTodaysData()
                }
            }
        }
    }
    
    func fetchTodaysData() {
        fetchStepCount()
        fetchHeartRate()
        fetchSleepData()
        fetchDailyCalories()
        fetchExerciseTime()
        fetchLatestWorkoutForToday()
        fetchWorkoutHistory()
    }
    
    private func fetchStepCount() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                self?.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHeartRate() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            
            DispatchQueue.main.async {
                self?.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSleepData() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: endOfYesterday, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, _ in
            guard let samples = samples as? [HKCategorySample] else { return }
            
            var totalSleepTime: TimeInterval = 0
            for sample in samples where sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            DispatchQueue.main.async {
                self?.sleepHours = totalSleepTime / 3600
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchDailyCalories() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                self?.dailyCalories = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchExerciseTime() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: exerciseTimeType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                self?.exerciseMinutes = sum.doubleValue(for: HKUnit.minute())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestWorkoutForToday() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let workout = samples?.first as? HKWorkout else {
                DispatchQueue.main.async {
                    self?.latestWorkout = nil
                }
                return
            }
            
            let duration = workout.duration
            let distance = workout.totalDistance?.doubleValue(for: HKUnit.mile()) ?? 0
            let calories = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            let workoutTypeString = workout.workoutActivityType.name
            
            self?.fetchWorkoutHeartRate(for: workout) { avgHeartRate in
                DispatchQueue.main.async {
                    self?.latestWorkout = WorkoutData(
                        startDate: workout.startDate,
                        duration: duration,
                        distance: distance,
                        heartRate: avgHeartRate,
                        calories: calories,
                        workoutType: workoutTypeString
                    )
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWorkoutHeartRate(for workout: HKWorkout, completion: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let avgHeartRate = result?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            completion(avgHeartRate)
        }
        
        healthStore.execute(query)
    }
    
    func getCurrentRoast() -> String {
        return RoastGenerator.generateRoast(
            stepCount: stepCount,
            heartRate: heartRate,
            sleepHours: sleepHours,
            workoutData: latestWorkout
        )
    }
    
    func checkForNewWorkoutAndNotify() {
        fetchLatestWorkoutForToday()
        
        // Remove delay for immediate response like Strava
        DispatchQueue.main.async {
            // Get current character for personalized notification
            let characterViewModel = self.getCharacterViewModel()
            let selectedCharacter = characterViewModel?.selectedCharacter
            
            if let workout = self.latestWorkout {
                var roast: String
                if let character = selectedCharacter {
                    // Character-specific SHORT roast
                    roast = RoastGenerator.generateShortWorkoutRoast(
                        stepCount: self.stepCount,
                        heartRate: self.heartRate,
                        sleepHours: self.sleepHours,
                        workoutData: workout,
                        character: character
                    )
                    NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast, characterName: character.name)
                    print("🎭 Character SHORT workout notification sent: \(character.name)")
                } else {
                    // Generic SHORT roast
                    roast = RoastGenerator.generateShortWorkoutRoast(
                        stepCount: self.stepCount,
                        heartRate: self.heartRate,
                        sleepHours: self.sleepHours,
                        workoutData: workout
                    )
                    NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast)
                    print("🏃‍♂️ Immediate SHORT workout notification sent!")
                }
            } else {
                let roast = RoastGenerator.generateNoWorkoutRoast(
                    stepCount: self.stepCount,
                    heartRate: self.heartRate,
                    sleepHours: self.sleepHours,
                    character: selectedCharacter
                )
                
                if let character = selectedCharacter {
                    NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast, characterName: character.name)
                } else {
                    NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast)
                }
            }
        }
    }
    
    // MARK: - Strava-like Immediate Workout Notifications
    
    /// Manually trigger workout completion notification (like Strava)
    func triggerWorkoutCompletionNotification() {
        fetchLatestWorkoutForToday()
        
        DispatchQueue.main.async {
            if let workout = self.latestWorkout {
                let roast = RoastGenerator.generateRoast(
                    stepCount: self.stepCount,
                    heartRate: self.heartRate,
                    sleepHours: self.sleepHours,
                    workoutData: workout
                )
                NotificationManager.shared.scheduleWorkoutRoast(roast: roast)
                print("🏃‍♂️ Strava-like workout completion notification triggered!")
                
                // Update last known workout date to prevent duplicates
                self.lastKnownWorkoutDate = workout.startDate
            }
        }
    }
    
    // MARK: - Active Workout Session Monitoring
    
    private var lastKnownWorkoutDate: Date?
    private var workoutObserverQuery: HKObserverQuery?
    private var activeWorkoutSessions: Set<UUID> = []
    private var workoutSessionQuery: HKObserverQuery?
    
    func setupBackgroundWorkoutMonitoring() {
        // Store the current latest workout date to track new ones
        fetchLatestWorkout { [weak self] workout in
            self?.lastKnownWorkoutDate = workout?.startDate
        }
        
        // Create observer query for workout data
        let query = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Workout observer query error: \(error)")
                completionHandler()
                return
            }
            
            print("🔥 Workout data changed - checking for new workout")
            self?.checkForNewWorkoutInBackground(completion: { _ in
                completionHandler()
            })
        }
        
        workoutObserverQuery = query
        healthStore.execute(query)
        
        // Enable background delivery for workout data
        enableBackgroundWorkoutDelivery()
        
        // Setup active workout session monitoring for Strava-like detection
        setupActiveWorkoutSessionMonitoring()
    }
    
    private func enableBackgroundWorkoutDelivery() {
        healthStore.enableBackgroundDelivery(for: workoutType, frequency: .immediate) { [weak self] success, error in
            if let error = error {
                print("Failed to enable background workout delivery: \(error)")
                return
            }
            
            if success {
                print("✅ Background workout delivery enabled")
                // Also enable for steps and calories for comprehensive monitoring
                self?.enableBackgroundStepDelivery()
                self?.enableBackgroundCalorieDelivery()
            }
        }
    }
    
    private func enableBackgroundStepDelivery() {
        healthStore.enableBackgroundDelivery(for: stepCountType, frequency: .hourly) { success, error in
            if let error = error {
                print("Failed to enable background step delivery: \(error)")
                return
            }
            if success {
                print("✅ Background step delivery enabled")
            }
        }
    }
    
    private func enableBackgroundCalorieDelivery() {
        healthStore.enableBackgroundDelivery(for: caloriesType, frequency: .hourly) { success, error in
            if let error = error {
                print("Failed to enable background calorie delivery: \(error)")
                return
            }
            if success {
                print("✅ Background calorie delivery enabled")
            }
        }
    }
    
    // MARK: - Active Workout Session Monitoring
    
    private func setupActiveWorkoutSessionMonitoring() {
        // Monitor for active workout changes
        workoutSessionQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Workout session query error: \(error)")
                completionHandler()
                return
            }
            
            print("🏃‍♂️ Checking active workout sessions...")
            self?.monitorActiveWorkoutSessions()
            completionHandler()
        }
        
        healthStore.execute(workoutSessionQuery!)
    }
    
    private func monitorActiveWorkoutSessions() {
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let samples = samples as? [HKWorkout] else { return }
            
            let currentSessions = Set(samples.map { $0.uuid })
            let knownSessions = self?.activeWorkoutSessions ?? Set()
            
            // Detect completed workouts (sessions that are no longer active)
            let completedSessions = knownSessions.subtracting(currentSessions)
            
            if !completedSessions.isEmpty {
                print("🔥 Detected \(completedSessions.count) completed workout session(s)!")
                
                // Get the most recent completed workout
                let recentWorkouts = samples.filter { completedSessions.contains($0.uuid) }
                if let mostRecentWorkout = recentWorkouts.sorted(by: { $0.endDate > $1.endDate }).first {
                    self?.handleWorkoutCompletion(workout: mostRecentWorkout)
                }
            }
            
            // Update active sessions
            self?.activeWorkoutSessions = currentSessions
            
            // If we have active workouts, check for completion more frequently
            if !currentSessions.isEmpty {
                print("🏃‍♂️ \(currentSessions.count) active workout session(s) detected")
            }
        }
        
        healthStore.execute(query)
    }
    
    private func handleWorkoutCompletion(workout: HKWorkout) {
        print("🎯 Workout completed: \(workout.workoutActivityType.name) - Duration: \(Int(workout.duration/60))min")
        
        // This line is not needed, remove the unnecessary HKWorkout creation
        
        // Generate and send roast immediately
        let duration = workout.duration
        let distance = workout.totalDistance?.doubleValue(for: HKUnit.mile()) ?? 0
        let calories = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
        let workoutTypeString = workout.workoutActivityType.name
        
        let workoutStruct = WorkoutData(
            startDate: workout.startDate,
            duration: duration,
            distance: distance,
            heartRate: 0, // Will be fetched asynchronously if needed
            calories: calories,
            workoutType: workoutTypeString
        )
        
        // Send immediate notification - Strava-like with character awareness!
        DispatchQueue.main.async {
            // Get current character for personalized notification
            let characterViewModel = self.getCharacterViewModel()
            let selectedCharacter = characterViewModel?.selectedCharacter
            
            var roast: String
            if let character = selectedCharacter {
                // Character-specific SHORT roast
                roast = RoastGenerator.generateShortWorkoutRoast(
                    stepCount: self.stepCount,
                    heartRate: self.heartRate,
                    sleepHours: self.sleepHours,
                    workoutData: workoutStruct,
                    character: character
                )
                
                // Send character-specific notification
                NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast, characterName: character.name)
                print("🎭 Character-specific SHORT notification sent for: \(character.name)")
            } else {
                // Default SHORT roast
                roast = RoastGenerator.generateShortWorkoutRoast(
                    stepCount: self.stepCount,
                    heartRate: self.heartRate,
                    sleepHours: self.sleepHours,
                    workoutData: workoutStruct
                )
                
                // Send generic notification
                NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast)
                print("🔥 Generic SHORT workout notification sent")
            }
            
            // Update last known workout date
            self.lastKnownWorkoutDate = workout.startDate
        }
    }
    
    private func checkForNewWorkoutInBackground(completion: @escaping (Bool) -> Void) {
        fetchLatestWorkout { [weak self] workout in
            guard let self = self else {
                completion(false)
                return
            }
            
            // Check if this is a new workout
            if let workout = workout,
               let lastKnownDate = self.lastKnownWorkoutDate {
                
                // If this workout is newer than our last known workout
                if workout.startDate > lastKnownDate {
                    print("🎉 New workout detected! \(workout.workoutType) - \(Int(workout.duration/60))min")
                    
                    // Update our last known workout date
                    self.lastKnownWorkoutDate = workout.startDate
                    
                    // Fetch current character for personalized notification
                    DispatchQueue.main.async {
                        // Get current character from CharacterViewModel
                        if let characterViewModel = self.getCharacterViewModel(),
                           let selectedCharacter = characterViewModel.selectedCharacter {
                            
                            let roast = RoastGenerator.generateComprehensiveDailyRoast(
                                stepCount: self.stepCount,
                                heartRate: self.heartRate,
                                sleepHours: self.sleepHours,
                                workoutData: workout,
                                character: selectedCharacter
                            )
                            
                            // Send character-specific small notification immediately
                            NotificationManager.shared.scheduleSmallWorkoutRoast(
                                roast: roast,
                                characterName: selectedCharacter.name
                            )
                        } else {
                            // Fallback to generic small notification
                            let roast = RoastGenerator.generateRoast(
                                stepCount: self.stepCount,
                                heartRate: self.heartRate,
                                sleepHours: self.sleepHours,
                                workoutData: workout
                            )
                            NotificationManager.shared.scheduleSmallWorkoutRoast(roast: roast)
                        }
                        
                        print("🔥 Strava-like workout notification sent immediately!")
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            } else {
                // First time setting up or no workout found
                if let workout = workout {
                    self.lastKnownWorkoutDate = workout.startDate
                }
                completion(false)
            }
        }
    }
    
    private func getCharacterViewModel() -> CharacterViewModel? {
        // Try to get the CharacterViewModel from the app's environment
        // This is a workaround since we can't directly access @EnvironmentObject from here
        return CharacterViewModel.shared
    }
    
    func stopBackgroundWorkoutMonitoring() {
        if let query = workoutObserverQuery {
            healthStore.stop(query)
            workoutObserverQuery = nil
            print("🛑 Workout background monitoring stopped")
        }
        
        // Disable background delivery
        healthStore.disableBackgroundDelivery(for: workoutType) { success, error in
            if let error = error {
                print("Failed to disable background workout delivery: \(error)")
            } else if success {
                print("✅ Background workout delivery disabled")
            }
        }
    }
    
    private func fetchLatestWorkout(completion: @escaping (WorkoutData?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            
            guard let workout = samples?.first as? HKWorkout else {
                completion(nil)
                return
            }
            
            let duration = workout.duration
            let distance = workout.totalDistance?.doubleValue(for: HKUnit.mile()) ?? 0
            let calories = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            let workoutTypeString = workout.workoutActivityType.name
            
            // Fetch heart rate data for this workout
            self.fetchWorkoutHeartRate(for: workout) { avgHeartRate in
                let workoutData = WorkoutData(
                    startDate: workout.startDate,
                    duration: duration,
                    distance: distance,
                    heartRate: avgHeartRate,
                    calories: calories,
                    workoutType: workoutTypeString
                )
                completion(workoutData)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWorkoutHistory() {
        let calendar = Calendar.current
        let now = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: thirtyDaysAgo, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 50, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let workouts = samples as? [HKWorkout] else { return }
            
            var historyItems: [WorkoutHistoryItem] = []
            let group = DispatchGroup()
            
            for workout in workouts {
                group.enter()
                self?.fetchWorkoutHeartRate(for: workout) { avgHeartRate in
                    let item = WorkoutHistoryItem(
                        date: workout.startDate,
                        workoutType: workout.workoutActivityType.name,
                        duration: workout.duration,
                        distance: workout.totalDistance?.doubleValue(for: HKUnit.mile()) ?? 0,
                        heartRate: avgHeartRate,
                        calories: workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                    )
                    historyItems.append(item)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self?.workoutHistory = historyItems.sorted { $0.date > $1.date }
            }
        }
        
        healthStore.execute(query)
    }
    
    func writeTestData() {
        writeStepCount(7542)
        writeWorkout(duration: 42 * 60, calories: 1257)
    }
    
    private func writeStepCount(_ steps: Int) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endTime = now
        
        let stepSample = HKQuantitySample(
            type: stepCountType,
            quantity: HKQuantity(unit: HKUnit.count(), doubleValue: Double(steps)),
            start: startOfDay,
            end: endTime
        )
        
        healthStore.save(stepSample) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Successfully wrote \(steps) steps to HealthKit")
                    self.fetchStepCount()
                } else if let error = error {
                    print("Failed to write steps: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func writeWorkout(duration: TimeInterval, calories: Double) {
        let startDate = Date().addingTimeInterval(-duration)
        let endDate = Date()
        
        let workout = HKWorkout(
            activityType: .running,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories),
            totalDistance: nil,
            metadata: nil
        )
        
        healthStore.save(workout) { success, error in
            if success {
                print("Successfully wrote workout: \(duration/60) mins, \(calories) calories")
            } else if let error = error {
                print("Failed to write workout: \(error.localizedDescription)")
            }
        }
    }
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .yoga: return "Yoga"
        case .traditionalStrengthTraining: return "Strength Training"
        case .crossTraining: return "Cross Training"
        case .functionalStrengthTraining: return "Functional Training"
        case .coreTraining: return "Core Training"
        default: return "Unknown"
        }
    }
}
