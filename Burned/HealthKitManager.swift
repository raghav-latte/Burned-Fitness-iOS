import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var stepCount: Int = 0
    @Published var heartRate: Double = 0
    @Published var sleepHours: Double = 0
    @Published var latestWorkout: WorkoutData?
    @Published var workoutHistory: [WorkoutHistoryItem] = []
    
    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    private let workoutType = HKObjectType.workoutType()
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    
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
            caloriesType
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
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
        fetchLatestWorkout()
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
    
    private func fetchLatestWorkout() {
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
        fetchLatestWorkout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let workout = self.latestWorkout {
                let roast = RoastGenerator.generateRoast(
                    stepCount: self.stepCount,
                    heartRate: self.heartRate,
                    sleepHours: self.sleepHours,
                    workoutData: workout
                )
                NotificationManager.shared.scheduleWorkoutRoast(roast: roast)
            } else {
                let roast = RoastGenerator.generateNoWorkoutRoast(
                    stepCount: self.stepCount,
                    heartRate: self.heartRate,
                    sleepHours: self.sleepHours
                )
                NotificationManager.shared.scheduleWorkoutRoast(roast: roast)
            }
        }
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