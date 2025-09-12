//
//  HomeTab+Helpers.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//

import SwiftUI
import HealthKit

extension HomeTab {
    
    // MARK: - Formatting Functions
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes == 0 {
            return "0m"
        }
        return "\(minutes)m"
    }
    
    func formatExerciseTime(_ minutes: Double) -> String {
        let mins = Int(minutes)
        if mins == 0 {
            return "0m"
        }
        return "\(mins)m"
    }
    
    // MARK: - Workout Helper Functions
    
    func getLastWorkoutWithin24Hours() -> WorkoutHistoryItem? {
        let now = Date()
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now) ?? now
        
        return healthKitManager.workoutHistory.first { workout in
            workout.date >= twentyFourHoursAgo
        }
    }
    
    // MARK: - Fitness Shame Score Functions
    
    func calculateShameScore() -> Double {
        let stepScore = min(Double(healthKitManager.stepCount) / 10000.0, 1.0) * 30 // 30% weight
        let workoutScore = (healthKitManager.latestWorkout?.duration ?? 0) > 0 ? 25.0 : 0 // 25% weight
        let calorieScore = min((healthKitManager.latestWorkout?.calories ?? 0) / 300.0, 1.0) * 20 // 20% weight
        let consistencyScore = healthKitManager.workoutHistory.count > 0 ? 25.0 : 0 // 25% weight
        
        let totalScore = stepScore + workoutScore + calorieScore + consistencyScore
        return 100 - totalScore // Invert to make it a "shame" score
    }
    
    func getShameScoreGradient() -> [Color] {
        let score = calculateShameScore()
        switch score {
        case 0...30: return [.green, .mint] // Great performance
        case 31...50: return [.yellow, .orange] // Average performance  
        case 51...75: return [.orange, .red] // Poor performance
        default: return [.red, .purple] // Shameful performance
        }
    }
    
    func getShameScoreLabel() -> String {
        let score = calculateShameScore()
        switch score {
        case 0...20: return "FITNESS HERO"
        case 21...40: return "DECENT HUMAN"
        case 41...60: return "COULD DO BETTER"
        case 61...80: return "DISAPPOINTING"
        default: return "PATHETIC"
        }
    }
    
    // MARK: - Character Mood Functions
    
    func getCharacterMoodStroke() -> Color {
        let score = calculateShameScore()
        switch score {
        case 0...30: return .green
        case 31...50: return .yellow  
        case 51...75: return .orange
        default: return .red
        }
    }
    
    func getCharacterMoodEmoji() -> String {
        guard let character = characterViewModel.selectedCharacter else { return "😐" }
        
        let score = calculateShameScore()
        switch character.name {
        case "Drill Sergeant":
            return score > 60 ? "😡" : (score > 30 ? "😤" : "💪")
        case "British Narrator":
            return score > 60 ? "🤨" : (score > 30 ? "🧐" : "😌")
        case "Your Ex (Female)":
            return score > 60 ? "🙄" : (score > 30 ? "😏" : "😘")
        case "Your Ex (Male)":
            return score > 60 ? "😤" : (score > 30 ? "🤔" : "😎")
        default:
            return "😐"
        }
    }
    
    func getCharacterMoodText() -> String {
        guard let character = characterViewModel.selectedCharacter else { return "Select a character" }
        
        let score = calculateShameScore()
        switch character.name {
        case "Drill Sergeant":
            return score > 60 ? "Extremely disappointed" : (score > 30 ? "Not impressed" : "Proud of your effort")
        case "British Narrator":
            return score > 60 ? "Observing poor habits" : (score > 30 ? "Documenting mediocrity" : "Witnessing excellence")
        case "Your Ex (Female)":
            return score > 60 ? "I told you so..." : (score > 30 ? "Could be better" : "Actually impressed")
        case "Your Ex (Male)":
            return score > 60 ? "This is why we broke up" : (score > 30 ? "Needs improvement bro" : "Not bad, not bad")
        default:
            return "Ready to roast"
        }
    }
    
    // MARK: - Character Gradient Helper
    
    func gradientForCharacter(_ name: String) -> Gradient {
        switch name {
        case "Drill Sergeant":
            return Gradient(colors: [Color.yellow.opacity(0.9), Color.green.opacity(0.9), Color.black])
        case "British Narrator":
            return Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4), Color.black])
        case "Your Ex (Female)":
            return Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.4), Color.black])
        case "Your Ex (Male)":
            return Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.4), Color.black])
        default:
            return Gradient(colors: [Color.gray.opacity(0.6), Color.black])
        }
    }
    
    // MARK: - Quick Improvement Function
    
    func triggerQuickImprovement() {
        let quickImprovementSuggestions = [
            "Take 100 steps right now - your score will thank you later.",
            "Do 10 burpees. Yes, right now. Stop making excuses.",
            "Walk to your kitchen and back 5 times. It's pathetic but it's a start.",
            "Stand up and do jumping jacks for 30 seconds. Your shame score is watching.",
            "Drop and give me 10 push-ups. Your character is judging your commitment.",
            "Walk around your room for 2 minutes. Even glacial movement is better than none.",
            "Do wall sits for 30 seconds. Your fitness score needs immediate intervention.",
            "Take the stairs instead of the elevator. Baby steps toward being less shameful."
        ]
        
        let motivationalRoast = quickImprovementSuggestions.randomElement() ?? "Move your body. Any movement is better than this pathetic score."
        speechManager.speakRoast(motivationalRoast)
    }
    
    // MARK: - Current Roast Text Helper
    
    func getCurrentRoastText() -> String {
        guard let character = characterViewModel.selectedCharacter else {
            return "Select a character to start getting roasted!"
        }
        
        // Generate a roast based on current fitness data
        let roast = RoastGenerator.generateRoast(
            stepCount: healthKitManager.stepCount,
            heartRate: healthKitManager.heartRate,
            sleepHours: healthKitManager.sleepHours,
            workoutData: healthKitManager.latestWorkout,
            character: character
        )
        
        return roast
    }
}
