import Foundation

struct WorkoutData {
    let duration: TimeInterval
    let distance: Double
    let heartRate: Double
    let calories: Double
    let workoutType: String
}

struct WorkoutHistoryItem: Identifiable {
    let id = UUID()
    let date: Date
    let workoutType: String
    let duration: TimeInterval
    let distance: Double
    let heartRate: Double
    let calories: Double
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}

class RoastGenerator {
    
    static func generateRoast(
        stepCount: Int,
        heartRate: Double,
        sleepHours: Double,
        workoutData: WorkoutData?,
        character: Character? = nil
    ) -> String {
        
        // Check for "Your Ex" character-specific roasts
        if let char = character, char.name == "Your Ex" {
            return generateExRoast(stepCount: stepCount, heartRate: heartRate, sleepHours: sleepHours, workoutData: workoutData)
        }
        
        if let workout = workoutData {
            return generateWorkoutRoast(workout: workout, stepCount: stepCount, heartRate: heartRate)
        }
        
        return generateNoWorkoutRoast(stepCount: stepCount, heartRate: heartRate, sleepHours: sleepHours, character: character)
    }
    
    static func generateExRoast(stepCount: Int, heartRate: Double, sleepHours: Double, workoutData: WorkoutData?) -> String {
        if let workout = workoutData {
            let minutes = Int(workout.duration) / 60
            let calories = Int(workout.calories)
            let distance = workout.distance
            let intensity = heartRate > 0 ? heartRate : workout.heartRate
            
            // Workout-based ex roasts
            if workout.duration < 900 { // Less than 15 minutes
                let exDurationRoasts = [
                    "\(minutes) minutes? Just like our relationship - you couldn't commit to anything substantial.",
                    "A \(minutes)-minute workout? Shorter than the time it took me to realize you weren't worth it.",
                    "\(minutes) minutes of effort? Still more than you ever put into us.",
                    "Only \(minutes) minutes? Your workouts last about as long as your promises did.",
                    "\(minutes) minutes? Even your exercise routine has commitment issues.",
                    "A \(minutes)-minute session? I see you're still allergic to putting in real effort."
                ]
                return exDurationRoasts.randomElement()!
            }
            
            if calories < 200 {
                let exCalorieRoasts = [
                    "\(calories) calories? You burned more energy making excuses when we were together.",
                    "Only \(calories) calories? Still putting in minimal effort, I see. Some things never change.",
                    "\(calories) calories burned? That's less energy than I wasted trying to fix you.",
                    "\(calories) calories? Even your metabolism is as lazy as your text responses were."
                ]
                return exCalorieRoasts.randomElement()!
            }
            
            let exWorkoutRoasts = [
                "Still working out alone, I see. At least the gym equipment won't ghost you.",
                "Look at you trying to get fit. Too bad you can't exercise away a terrible personality.",
                "Working on yourself now? Where was this energy when I asked you to work on us?",
                "Finally hitting the gym? Trying to impress someone new already?",
                "All this effort for fitness, yet you couldn't lift a finger to save our relationship.",
                "Sweating it out at the gym won't help you run from your emotional baggage.",
                "Nice workout. Still can't outrun the fact that you fumbled the best thing you had."
            ]
            return exWorkoutRoasts.randomElement()!
        } else {
            // No workout ex roasts
            let exNoWorkoutRoasts = [
                "No workout today? Just like old times - all talk, no action.",
                "Skipping the gym again? Your consistency is as reliable as your 'I'll change' promises.",
                "No exercise? Still choosing the couch over self-improvement. Classic you.",
                "Rest day? More like every day is a rest day from personal growth.",
                "No workout? I see you're still married to mediocrity.",
                "Avoiding the gym like you avoided difficult conversations. Some habits die hard.",
                "Zero effort today? Reminds me why we didn't work out... literally and figuratively.",
                "No exercise again? Your dedication to fitness matches your dedication to relationships.",
                "Skipping workouts like you skipped my calls. At least you're consistent.",
                "Another lazy day? No wonder I upgraded.",
                "No gym today? Still putting more effort into excuses than excellence.",
                "Couch potato mode activated? Just like when we'd make plans and you'd cancel last minute."
            ]
            
            if stepCount < 1000 {
                let exLowStepRoasts = [
                    "\(stepCount) steps? Even less mobile than your emotional availability.",
                    "Only \(stepCount) steps? You moved more when you were walking away from our problems.",
                    "\(stepCount) steps today? Still going nowhere fast, I see.",
                    "Step count: \(stepCount). Life progress: Also \(stepCount)."
                ]
                return exLowStepRoasts.randomElement()!
            }
            
            return exNoWorkoutRoasts.randomElement()!
        }
    }
    
    static func generateNoWorkoutRoast(stepCount: Int, heartRate: Double, sleepHours: Double, character: Character? = nil) -> String {
        guard let character = character else {
            return "Time to get moving!"
        }
        
        // Use character-specific no workout roasts
        let roastArray = RoastLibrary.getRoastArray(for: character, type: .noWorkout)
        return RoastLibrary.getRandomRoast(from: roastArray)
    }
    
    private static func generateWorkoutRoast(workout: WorkoutData, stepCount: Int, heartRate: Double) -> String {
        let pace = workout.distance > 0 ? workout.duration / (workout.distance * 60) : 0
        let intensity = heartRate > 0 ? heartRate : workout.heartRate
        let minutes = Int(workout.duration) / 60
        let calories = Int(workout.calories)
        let distance = workout.distance
        
        // Ultra-specific duration roasts with actual data
        if workout.duration < 900 { // Less than 15 minutes
            let specificDurationRoasts = [
                "\(minutes) minutes? My toddler crawls more than you just worked out.",
                "A \(minutes)-minute workout? Even commercial breaks show more commitment.",
                "\(minutes) minutes of 'exercise'? I've seen people spend longer choosing what to watch on Netflix.",
                "That \(minutes)-minute session barely qualifies as movement, let alone a workout.",
                "\(minutes) minutes? Your attention span for TikToks is longer than this pathetic attempt.",
                "A \(minutes)-minute workout? My phone's screen timeout lasts longer.",
                "\(minutes) minutes of exercise? That's not even enough time to properly warm up your excuses.",
                "You worked out for \(minutes) minutes? Even bathroom breaks require more time and effort."
            ]
            return specificDurationRoasts.randomElement()!
        }
        
        // Ultra-specific heart rate roasts
        if intensity < 100 {
            let specificHeartRateRoasts = [
                "\(Int(intensity)) BPM? Congratulations, you've achieved the heart rate of someone taking a leisurely nap.",
                "A peak heart rate of \(Int(intensity))? My resting heart rate shows more enthusiasm than your workout.",
                "\(Int(intensity)) BPM during exercise? Even my anxiety attacks are more intense than this.",
                "Your maximum heart rate of \(Int(intensity))? I've seen people get more excited about elevator music.",
                "\(Int(intensity)) BPM? That's not cardio, that's just existing with mild discomfort.",
                "Heart rate: \(Int(intensity)). Effort level: medically concerning levels of low.",
                "\(Int(intensity)) BPM? Even browsing social media gets my heart pumping harder than your 'workout'."
            ]
            return specificHeartRateRoasts.randomElement()!
        }
        
        // Ultra-specific pace roasts with actual numbers
        if pace > 12 && workout.workoutType.contains("Running") {
            let specificPaceRoasts = [
                "\(String(format: "%.1f", pace)) minutes per mile? Geological formations move faster than you.",
                "A \(String(format: "%.1f", pace))-minute mile pace? Even continental drift shows more urgency.",
                "\(String(format: "%.1f", pace)) minutes per mile? At this speed, seasons will change before you finish a 5K.",
                "Your pace of \(String(format: "%.1f", pace)) minutes per mile makes rush hour traffic look speedy.",
                "\(String(format: "%.1f", pace))-minute miles? I've seen glaciers with better forward momentum.",
                "Running at \(String(format: "%.1f", pace)) minutes per mile? Even my grandmother's mall walking group would lap you.",
                "\(String(format: "%.1f", pace)) minutes per mile? That's not running, that's aggressive standing."
            ]
            return specificPaceRoasts.randomElement()!
        }
        
        // Ultra-specific calorie roasts with exact numbers
        if workout.calories < 150 {
            let specificCalorieRoasts = [
                "\(calories) calories? Congratulations, you've earned yourself exactly one bite of an apple.",
                "You burned \(calories) calories. That's literally less energy than it takes to digest a carrot.",
                "\(calories) calories burned? You could've achieved the same result by walking to your mailbox.",
                "A whopping \(calories) calories? That barely covers the energy cost of opening this app.",
                "\(calories) calories? You've burned less energy than your phone did tracking this pathetic workout.",
                "You torched a massive \(calories) calories! That's almost enough to offset half a grape.",
                "\(calories) calories burned? I've seen people expend more energy deciding what to watch on Netflix.",
                "Your \(calories)-calorie burn is so low, calculators everywhere are questioning their math."
            ]
            return specificCalorieRoasts.randomElement()!
        }
        
        // Ultra-specific distance roasts with actual measurements
        if workout.distance < 1.0 && workout.workoutType.contains("Running") {
            let specificDistanceRoasts = [
                "\(String(format: "%.2f", distance)) miles? That's not a run, that's a trip to check your mailbox.",
                "You covered \(String(format: "%.2f", distance)) miles? Even my daily walk to the kitchen is more impressive.",
                "\(String(format: "%.2f", distance)) miles of 'running'? I've seen people pace longer distances while on hold with customer service.",
                "A \(String(format: "%.2f", distance))-mile run? That distance wouldn't even get you out of most parking lots.",
                "\(String(format: "%.2f", distance)) miles? Hamsters on wheels are putting you to shame right now.",
                "You ran \(String(format: "%.2f", distance)) miles? That's basically a long walk to the end of your driveway and back.",
                "\(String(format: "%.2f", distance)) miles? I've seen people cover more ground pacing nervously."
            ]
            return specificDistanceRoasts.randomElement()!
        }
        
        // Ultra-specific multi-metric roasts combining actual data
        let specificCrossoverRoasts = [
            "\(minutes) minutes, \(calories) calories, \(Int(intensity)) BPM? I've seen more intensity in a library study session.",
            "Let me get this straight: \(String(format: "%.2f", distance)) miles in \(minutes) minutes at \(calories) calories? My phone's battery worked harder than you did.",
            "\(minutes)-minute workout, \(Int(intensity)) BPM heart rate, and \(calories) calories burned? That's not exercise, that's aggressive meditation.",
            "So you spent \(minutes) minutes to burn \(calories) calories at \(Int(intensity)) BPM? Sleeping would've been more productive.",
            "\(String(format: "%.2f", distance)) miles, \(calories) calories, \(minutes) minutes? You've achieved the fitness equivalent of participation trophy levels.",
            "Your stats: \(minutes) min, \(calories) cal, \(Int(intensity)) BPM. Even my calculator is embarrassed by those numbers.",
            "\(minutes) minutes of 'exercise' for \(calories) calories? You could've burned more energy being disappointed in yourself."
        ]
        
        return specificCrossoverRoasts.randomElement()!
    }
    
    static func generateStepRoast(stepCount: Int, character: Character? = nil) -> String {
        guard let character = character else {
            return "Time to get moving!"
        }
        
        // Use specific number-based roasts for more personalized feedback
        return RoastLibrary.getSpecificStepRoast(stepCount: stepCount, character: character)
    }
    
    static func generateCalorieRoast(calories: Double, character: Character? = nil) -> String {
        let cal = Int(calories)
        
        guard let character = character else {
            return "Time to burn some calories!"
        }
        
        // Use specific number-based roasts for more personalized feedback
        return RoastLibrary.getSpecificCalorieRoast(calories: cal, character: character)
    }
    
    static func generateDurationRoast(duration: TimeInterval, character: Character? = nil) -> String {
        let minutes = Int(duration) / 60
        
        guard let character = character else {
            return "Time for a longer workout!"
        }
        
        // Use specific number-based roasts for more personalized feedback
        return RoastLibrary.getSpecificDurationRoast(minutes: minutes, character: character)
    }
    
}