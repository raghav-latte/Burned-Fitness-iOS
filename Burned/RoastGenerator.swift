import Foundation

struct WorkoutData {
    let startDate: Date
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
        
        guard let character = character else {
            return "Time to get roasted!"
        }
        
        // Generate comprehensive daily roast considering all activities
        return generateComprehensiveDailyRoast(
            stepCount: stepCount,
            heartRate: heartRate,
            sleepHours: sleepHours,
            workoutData: workoutData,
            character: character
        )
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
        print("🎯 generateNoWorkoutRoast called")
        print("📊 Parameters: steps=\(stepCount), character=\(character?.name ?? "nil")")
        
        guard let character = character else {
            print("❌ No character provided")
            return "Time to get moving!"
        }
        
        print("🔍 Getting roast array for character: \(character.name)")
        // Use character-specific no workout roasts
        let roastArray = RoastLibrary.getRoastArray(for: character, type: .noWorkout)
        print("📝 Got \(roastArray.count) roasts from library")
        
        let roast = RoastLibrary.getRandomRoast(from: roastArray)
        print("✅ Selected roast: \(roast)")
        return roast
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
        
        // Try cached roast first
        if let cachedRoast = RoastCache.getCachedRoast(for: character, stepCount: stepCount, calories: 0, duration: 0) {
            return cachedRoast
        }
        
        // Fall back to library-generated roasts
        return RoastLibrary.getSpecificStepRoast(stepCount: stepCount, character: character)
    }
    
    static func generateCalorieRoast(calories: Double, character: Character? = nil) -> String {
        let cal = Int(calories)
        
        guard let character = character else {
            return "Time to burn some calories!"
        }
        
        // Try cached roast first
        if let cachedRoast = RoastCache.getCachedRoast(for: character, stepCount: 0, calories: calories, duration: 0) {
            return cachedRoast
        }
        
        // Fall back to library-generated roasts
        return RoastLibrary.getSpecificCalorieRoast(calories: cal, character: character)
    }
    
    static func generateDurationRoast(duration: TimeInterval, character: Character? = nil) -> String {
        let minutes = Int(duration) / 60
        
        guard let character = character else {
            return "Time for a longer workout!"
        }
        
        // Try cached roast first
        if let cachedRoast = RoastCache.getCachedRoast(for: character, stepCount: 0, calories: 0, duration: duration) {
            return cachedRoast
        }
        
        // Fall back to library-generated roasts
        return RoastLibrary.getSpecificDurationRoast(minutes: minutes, character: character)
    }
    
    static func generateComprehensiveDailyRoast(
        stepCount: Int,
        heartRate: Double,
        sleepHours: Double,
        workoutData: WorkoutData?,
        character: Character
    ) -> String {
        
        let minutes = Int(workoutData?.duration ?? 0) / 60
        let calories = Int(workoutData?.calories ?? 0)
        let distance = workoutData?.distance ?? 0
        
        // Check if user has done literally nothing worth roasting
        if stepCount < 500 && minutes == 0 && calories == 0 {
            return generateTooLazyToRoast(character: character)
        }
        
        // Generate comprehensive roast combining multiple metrics
        var roastParts: [String] = []
        
        // Step-based commentary
        if stepCount < 2000 {
            roastParts.append(getStepCommentary(stepCount: stepCount, character: character))
        }
        
        // Workout-based commentary  
        if minutes > 0 {
            if minutes < 15 {
                roastParts.append(getDurationCommentary(minutes: minutes, character: character))
            }
            if calories < 200 && calories > 0 {
                roastParts.append(getCalorieCommentary(calories: calories, character: character))
            }
        } else if stepCount >= 2000 {
            // Has steps but no formal workout
            roastParts.append(getNoWorkoutButStepsCommentary(stepCount: stepCount, character: character))
        }
        
        // Sleep commentary if relevant
        if sleepHours > 0 && sleepHours < 6 {
            roastParts.append(getSleepCommentary(sleepHours: sleepHours, character: character))
        }
        
        // Heart rate commentary if they worked out
        if let workout = workoutData, workout.heartRate > 0 && workout.heartRate < 120 {
            roastParts.append(getHeartRateCommentary(heartRate: workout.heartRate, character: character))
        }
        
        // If somehow still empty, give default
        if roastParts.isEmpty {
            roastParts.append(RoastLibrary.getRandomRoast(from: RoastLibrary.getRoastArray(for: character, type: .noWorkout)))
        }
        
        // Combine the parts into a cohesive roast
        return combineRoastParts(roastParts, character: character)
    }
    
    static func generateTooLazyToRoast(character: Character) -> String {
        switch character.name {
        case "Drill Sergeant":
            return "MAGGOT! You haven't done anything worthy of a roast today! Even my disappointment needs more effort to properly form! COME BACK WHEN YOU'VE ACTUALLY MOVED!"
            
        case "British Narrator":
            return "Observe this fascinating specimen who has achieved such profound inactivity that even roasting proves pointless. A truly remarkable dedication to doing absolutely nothing."
            
        case "Your Ex (Female)":
            return "You know what? I'm not even wasting my energy roasting you today. You couldn't even manage to do something worth making fun of. That's a new level of pathetic."
            
        case "Your Ex (Male)":
            return "Bro, seriously? Not even worth my breath today. At least when we were together you managed to disappoint me in interesting ways. This is just boring."
            
        case "Your Ex (Female)", "Your Ex (Male)":
            return "You know what? I'm not even wasting my energy roasting you today. You couldn't even manage to do something worth making fun of. That's a new level of pathetic."
            
        default:
            return "You haven't done enough today to even deserve a proper roast. That's impressive in its own way."
        }
    }
    
    static func getStepCommentary(stepCount: Int, character: Character) -> String {
        return RoastLibrary.getSpecificStepRoast(stepCount: stepCount, character: character)
    }
    
    static func getDurationCommentary(minutes: Int, character: Character) -> String {
        return RoastLibrary.getSpecificDurationRoast(minutes: minutes, character: character)
    }
    
    static func getCalorieCommentary(calories: Int, character: Character) -> String {
        return RoastLibrary.getSpecificCalorieRoast(calories: calories, character: character)
    }
    
    static func getSleepCommentary(sleepHours: Double, character: Character) -> String {
        switch character.name {
        case "Drill Sergeant":
            return "SOLDIER! Only \(String(format: "%.1f", sleepHours)) hours of sleep? No wonder you're moving like a zombie!"
            
        case "British Narrator":
            return "Remarkably, this creature functions on merely \(String(format: "%.1f", sleepHours)) hours of rest, explaining its rather sluggish locomotion."
            
        case "Your Ex (Female)":
            return "Only \(String(format: "%.1f", sleepHours)) hours of sleep? Still can't manage basic self-care, I see. Some things never change."
            
        case "Your Ex (Male)":
            return "Bro, \(String(format: "%.1f", sleepHours)) hours of sleep? No wonder you're performing at half capacity. Classic you."
            
        case "Your Ex (Female)":
            return "\(String(format: "%.1f", sleepHours)) hours? Still can't manage basic self-care, I see. No wonder you're performing so poorly."
            
        default:
            return "Only \(String(format: "%.1f", sleepHours)) hours of sleep?"
        }
    }
    
    static func getHeartRateCommentary(heartRate: Double, character: Character) -> String {
        switch character.name {
        case "Drill Sergeant":
            return "Your heart rate barely reached \(Int(heartRate)) BPM! My grandmother walks faster than your 'workout'!"
            
        case "British Narrator":
            return "Fascinating! A peak heart rate of merely \(Int(heartRate)) BPM during what supposedly qualifies as exercise."
            
        case "Your Ex (Female)":
            return "Heart rate of \(Int(heartRate))? You're barely trying. Just like when we were together."
            
        case "Your Ex (Male)":
            return "Bro, \(Int(heartRate)) BPM? I've seen more excitement watching paint dry. Put some effort in!"
            
        case "Your Ex (Female)":
            return "\(Int(heartRate)) BPM? You're barely trying. Just like when we were together, putting in minimal effort."
            
        default:
            return "Heart rate only reached \(Int(heartRate)) BPM?"
        }
    }
    
    static func getNoWorkoutButStepsCommentary(stepCount: Int, character: Character) -> String {
        switch character.name {
        case "Drill Sergeant":
            return "\(stepCount) steps but no real workout? You think casual strolling counts as training, MAGGOT?"
            
        case "British Narrator":
            return "While we observe \(stepCount) steps of ambulation, this creature lacks structured physical exertion. Peculiar behavior."
            
        case "Your Ex (Female)":
            return "\(stepCount) steps but no actual workout? That's like having potential but no follow-through. Sound familiar?"
            
        case "Your Ex (Male)":
            return "Bro, \(stepCount) steps but couldn't commit to a real workout? Classic commitment issues."
            
        case "Your Ex (Female)":
            return "\(stepCount) steps but no actual workout? That's like having potential but no follow-through. Sound familiar?"
            
        default:
            return "\(stepCount) steps but no formal workout?"
        }
    }
    
    static func combineRoastParts(_ parts: [String], character: Character) -> String {
        if parts.count == 1 {
            return parts[0]
        } else if parts.count == 2 {
            return "\(parts[0]) \(parts[1])"
        } else {
            let firstPart = parts[0]
            let lastPart = parts.last!
            let middleParts = parts.dropFirst().dropLast().joined(separator: ". ")
            
            if middleParts.isEmpty {
                return "\(firstPart) \(lastPart)"
            } else {
                return "\(firstPart) \(middleParts). \(lastPart)"
            }
        }
    }
    
}