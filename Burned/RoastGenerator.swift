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
        workoutData: WorkoutData?
    ) -> String {
        
        if let workout = workoutData {
            return generateWorkoutRoast(workout: workout, stepCount: stepCount, heartRate: heartRate)
        }
        
        return generateNoWorkoutRoast(stepCount: stepCount, heartRate: heartRate, sleepHours: sleepHours)
    }
    
    static func generateNoWorkoutRoast(stepCount: Int, heartRate: Double, sleepHours: Double) -> String {
        let noWorkoutRoasts = [
            "No workout today? Your potential called — it's filing a missing person report.",
            "Rest day #47? Even your excuses need a workout at this point.",
            "Your commitment to fitness is like Wi-Fi in elevators — non-existent.",
            "Today's workout status: As missing as your motivation.",
            "Even your shadow is disappointed in you right now.",
            "Your fitness tracker is questioning its life choices.",
            "Netflix has seen more action than your running shoes.",
            "Your couch has permanent indentations from your dedication.",
            "If avoiding exercise was an Olympic sport, you'd be breaking records.",
            "Your muscles are filing for unemployment benefits.",
            "The gym membership you bought is basically charity at this point.",
            "Your workout clothes are gathering more dust than museum artifacts.",
            "Even sloths are starting to feel superior to you.",
            "Your heart rate monitor thinks it's broken because you never use it.",
            "If laziness burned calories, you'd be dangerously underweight by now."
        ]
        
        if stepCount < 500 {
            let lowStepRoasts = [
                "Step count so low I thought your phone was charging all day.",
                "You've taken more screenshots than steps today.",
                "Wow. You're single-handedly keeping the couch industry alive.",
                "Fitbit would've just given up on you by now.",
                "Your step counter is having an existential crisis.",
                "Even statues move more than you do.",
                "Your daily steps wouldn't even cover a grocery store aisle.",
                "Houseplants are getting more exercise than you."
            ]
            return lowStepRoasts.randomElement()!
        }
        
        return noWorkoutRoasts.randomElement()!
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
    
}