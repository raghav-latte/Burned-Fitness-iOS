import Foundation

struct RoastCache {
    
    // MARK: - Common Roast Scenarios
    
    static let commonScenarios: [String: [String]] = [
        // Low step counts
        "steps_under_500": [
            "Step count so low I thought your phone was charging all day.",
            "You've taken more screenshots than steps today.",
            "Even statues move more than you do."
        ],
        
        "steps_under_2000": [
            "That's cute. Most people walk more just thinking about exercise.",
            "You're basically a professional couch potato with delusions of activity."
        ],
        
        // Low calories
        "calories_under_100": [
            "Congratulations, you've earned yourself exactly one bite of an apple.",
            "That calorie burn couldn't power a night light.",
            "You've burned more energy being disappointed in yourself."
        ],
        
        // Short workouts
        "duration_under_15": [
            "That wasn't a workout, that was a commercial break.",
            "Even bathroom breaks require more commitment than this.",
            "My warm-up lasts longer than your entire session."
        ],
        
        // No workout
        "no_workout": [
            "No workout today? Your potential called — it's filing a missing person report.",
            "Even your shadow is disappointed in you right now.",
            "Your commitment to fitness is like Wi-Fi in elevators — non-existent."
        ]
    ]
    
    // MARK: - Character-Specific Pre-Generated Roasts
    
    static let characterRoasts: [String: [String: [String]]] = [
        "Drill Sergeant": [
            "low_performance": [
                "PATHETIC! I've seen more intensity in a chess match!",
                "SOLDIER! Your fitness level is lower than a snake's belly!",
                "DISGRACEFUL! Even my whistle gets more exercise than you!"
            ],
            "medium_performance": [
                "WEAK! That's barely enough to qualify as movement, recruit!",
                "MEDIOCRE! You might survive basic training... maybe.",
                "ACCEPTABLE! Finally showing some effort, soldier!"
            ]
        ],
        
        "British Narrator": [
            "low_performance": [
                "Here we observe a creature that has mastered the art of calorie conservation.",
                "Fascinating! This specimen has achieved furniture-level mobility.",
                "In nature's grand design, this being has chosen minimal movement."
            ],
            "medium_performance": [
                "This creature shows promising signs of biological activity.",
                "Observe this modest progress in human locomotion.",
                "Remarkable! Signs that this species has discovered movement."
            ]
        ],
        
        "Your Ex (Female)": [
            "low_performance": [
                "Still choosing the couch over self-improvement. Classic you.",
                "Your dedication to fitness matches your dedication to relationships.",
                "Your effort's as dead as your promises to change."
            ],
            "medium_performance": [
                "Getting warmer, unlike your cold heart.",
                "Look at you actually committing to something for once.",
                "Wow, actually showing effort. New person must be special."
            ]
        ],
        
        "Your Ex (Male)": [
            "low_performance": [
                "Bro, your form is still terrible and you're still not listening to my advice. Typical.",
                "Your dedication to fitness matches your dedication to relationships.",
                "Still failing at self-improvement, just like you failed me."
            ],
            "medium_performance": [
                "Getting warmer, unlike your cold heart.",
                "Look at you actually committing to something for once.",
                "Finally putting in work. Wish you'd done that for us."
            ]
        ],
        
        "Your Ex": [
            "low_performance": [
                "Bro, your form is still terrible and you're still not listening to my advice. Typical.",
                "Still choosing the couch over self-improvement. Classic you.",
                "Your dedication to fitness matches your dedication to relationships."
            ],
            "medium_performance": [
                "Getting warmer, unlike your cold heart.",
                "Look at you actually committing to something for once.",
                "Wow, actually showing effort. New person must be special."
            ]
        ],
        
        "The Savage": [
            "low_performance": [
                "Your fitness level is so low, even your shadow is embarrassed.",
                "You've achieved legendary status in the Hall of Disappointment.",
                "Even procrastination thinks you're lazy, and that's saying something."
            ],
            "medium_performance": [
                "Not terrible, but let's see if you can keep this up for more than a day.",
                "Finally, some actual effort. Don't let it go to your head.",
                "You're basically a professional couch warmer with delusions of mobility."
            ]
        ]
    ]
    
    // MARK: - Performance Categorization
    
    static func getPerformanceCategory(stepCount: Int, calories: Double, duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        
        // Low performance indicators
        if stepCount < 1000 || calories < 100 || minutes < 15 {
            return "low_performance"
        }
        
        // Medium performance
        if stepCount < 5000 || calories < 300 || minutes < 30 {
            return "medium_performance"
        }
        
        // High performance (will fall back to API generation)
        return "high_performance"
    }
    
    static func getScenarioKey(stepCount: Int, calories: Double, duration: TimeInterval) -> String? {
        let minutes = Int(duration) / 60
        let cal = Int(calories)
        
        // No workout scenario
        if minutes == 0 && cal == 0 && stepCount < 1000 {
            return "no_workout"
        }
        
        // Step scenarios
        if stepCount < 500 {
            return "steps_under_500"
        } else if stepCount < 2000 {
            return "steps_under_2000"
        }
        
        // Calorie scenarios
        if cal < 100 {
            return "calories_under_100"
        }
        
        // Duration scenarios
        if minutes < 15 && minutes > 0 {
            return "duration_under_15"
        }
        
        return nil
    }
    
    // MARK: - Cache Management
    
    static func getCachedRoast(for character: Character, stepCount: Int, calories: Double, duration: TimeInterval) -> String? {
        let characterName = character.name
        
        // Try character-specific roasts first
        let performanceCategory = getPerformanceCategory(stepCount: stepCount, calories: calories, duration: duration)
        
        if let characterRoasts = characterRoasts[characterName],
           let categoryRoasts = characterRoasts[performanceCategory],
           !categoryRoasts.isEmpty {
            return categoryRoasts.randomElement()
        }
        
        // Fall back to scenario-based roasts
        if let scenarioKey = getScenarioKey(stepCount: stepCount, calories: calories, duration: duration),
           let scenarioRoasts = commonScenarios[scenarioKey],
           !scenarioRoasts.isEmpty {
            return scenarioRoasts.randomElement()
        }
        
        return nil
    }
    
    // MARK: - Pre-Generation Suggestions
    
    static let suggestedPreGeneration: [(stepCount: Int, calories: Double, duration: TimeInterval, description: String)] = [
        // No workout scenarios
        (0, 0, 0, "No workout at all"),
        (500, 0, 0, "Very low steps, no workout"),
        (1000, 0, 0, "Low steps, no workout"),
        
        // Short workout scenarios
        (2000, 50, 300, "5-minute light workout"),
        (3000, 100, 600, "10-minute moderate workout"),
        (4000, 150, 900, "15-minute decent workout"),
        
        // Low calorie scenarios
        (5000, 75, 1200, "20-minute low-intensity"),
        (6000, 125, 1500, "25-minute easy workout"),
        
        // Medium scenarios
        (8000, 200, 1800, "30-minute good workout"),
        (10000, 300, 2400, "40-minute solid session"),
        
        // Step-focused scenarios
        (15000, 150, 900, "High steps, short workout"),
        (20000, 200, 1200, "Very high steps, medium workout")
    ]
}

// MARK: - Audio Cache Manager

class AudioCacheManager: ObservableObject {
    private let cacheDirectory: URL
    private let maxCacheSize: Int = 10 * 1024 * 1024 // 10MB (reduced from 50MB)
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("RoastCache")
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getCacheKey(for roastText: String, character: Character) -> String {
        let combined = "\(character.name)_\(roastText)"
        return combined.hash.description
    }
    
    func getCachedAudio(for roastText: String, character: Character) -> Data? {
        let key = getCacheKey(for: roastText, character: character)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).m4a")
        
        return try? Data(contentsOf: fileURL)
    }
    
    func cacheAudio(_ audioData: Data, for roastText: String, character: Character) {
        let key = getCacheKey(for: roastText, character: character)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).m4a")
        
        do {
            try audioData.write(to: fileURL)
            cleanupCacheIfNeeded()
        } catch {
            print("Failed to cache audio: \(error)")
        }
    }
    
    private func cleanupCacheIfNeeded() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
            
            let totalSize = files.compactMap { url -> Int64? in
                try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init)
            }.reduce(0, +)
            
            if totalSize > maxCacheSize {
                // Remove oldest files first
                let sortedFiles = files.compactMap { url -> (URL, Date)? in
                    guard let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate else { return nil }
                    return (url, date)
                }.sorted { $0.1 < $1.1 }
                
                // Remove oldest 50% of files (more aggressive cleanup)
                let filesToRemove = sortedFiles.prefix(sortedFiles.count / 2)
                for (fileURL, _) in filesToRemove {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Cache cleanup failed: \(error)")
        }
    }
    
    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        createCacheDirectory()
    }
    
    func getCacheSize() -> String {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            let totalBytes = files.compactMap { url -> Int64? in
                try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init)
            }.reduce(0, +)
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: totalBytes)
        } catch {
            return "Unknown"
        }
    }
}