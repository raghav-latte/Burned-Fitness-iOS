//
//  HomeTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI
import HealthKit
import RevenueCat

struct HomeTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @StateObject private var speechManager = ElevenLabsManager.shared
    @State private var selectedPersona = "🔥"
    
    private let personas = [
        ("🔥", "Savage", "No mercy mode"),
        ("😈", "Brutal", "Maximum damage"),
        ("💀", "Ruthless", "Emotional destruction"),
        ("🤡", "Sarcastic", "Witty roasts")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Hero Roast Banner
                    VStack(spacing: 20) {
                        // Animated persona avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.orange, .red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 120, height: 120)
                                .scaleEffect(speechManager.isSpeaking ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isSpeaking)
                            
                            Text(selectedPersona)
                                .font(.system(size: 60))
                                .scaleEffect(speechManager.isSpeaking ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: speechManager.isSpeaking)
                        }
                        
                        // Dynamic roast text
                        Text(speechManager.isSpeaking ? "Roasting you..." : "Ready to get burned?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(speechManager.isLoading ? 0.5 : 1.0)
                    }
                    .padding(.top, 20)
                    
                    // Last Workout Section (if within 24 hours)
                    if let lastWorkout = getLastWorkoutWithin24Hours() {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Last Workout")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Tap to roast")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            
                            HStack {
                                Spacer()
                                RecentWorkoutCardView(
                                    workout: lastWorkout,
                                    speechManager: speechManager
                                )
                                Spacer()
                            }
                        }
                    }
                    
                    // Three Big Stat Blocks
                    VStack(spacing: 20) {
                        // Steps Block
                        StatBlockView(
                            title: "STEPS",
                            value: "\(healthKitManager.stepCount)",
                            color: .blue,
                            icon: "figure.walk"
                        ) {
                            let roast = RoastGenerator.generateStepRoast(stepCount: healthKitManager.stepCount, character: characterViewModel.selectedCharacter)
                            speechManager.speakRoast(roast)
                        }
                        
                        // Calories Block
                        StatBlockView(
                            title: "CALORIES",
                            value: "\(Int(healthKitManager.latestWorkout?.calories ?? 0))",
                            color: .orange,
                            icon: "flame.fill"
                        ) {
                            let roast = RoastGenerator.generateCalorieRoast(calories: healthKitManager.latestWorkout?.calories ?? 0, character: characterViewModel.selectedCharacter)
                            speechManager.speakRoast(roast)
                        }
                        
                        // Workout Time Block
                        StatBlockView(
                            title: "WORKOUT TIME",
                            value: formatDuration(healthKitManager.latestWorkout?.duration ?? 0),
                            color: .green,
                            icon: "timer"
                        ) {
                            let roast = RoastGenerator.generateDurationRoast(duration: healthKitManager.latestWorkout?.duration ?? 0, character: characterViewModel.selectedCharacter)
                            speechManager.speakRoast(roast)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Burn Me Again Button
                    Button(action: {
                        let roast = RoastGenerator.generateRoast(
                            stepCount: healthKitManager.stepCount,
                            heartRate: healthKitManager.heartRate,
                            sleepHours: healthKitManager.sleepHours,
                            workoutData: healthKitManager.latestWorkout,
                            character: characterViewModel.selectedCharacter
                        )
                        speechManager.speakRoast(roast)
                    }) {
                        HStack(spacing: 12) {
                            if speechManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "flame.fill")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            
                            Text("BURN ME AGAIN")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.orange, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                        .scaleEffect(speechManager.isSpeaking ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: speechManager.isSpeaking)
                    }
                    .disabled(speechManager.isSpeaking || speechManager.isLoading)
                    .padding(.horizontal, 20)
                    
                    // Recent Workouts Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Recent Workouts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("Tap to roast")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        
                        if healthKitManager.workoutHistory.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "figure.run.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No recent workouts")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                
                                Text("Time to get moving and earn some roasts!")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6).opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(healthKitManager.workoutHistory.prefix(5).enumerated()), id: \.offset) { index, workout in
                                        RecentWorkoutCardView(
                                            workout: workout,
                                            speechManager: speechManager
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            healthKitManager.fetchWorkoutHistory()
            
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes == 0 {
            return "0m"
        }
        return "\(minutes)m"
    }
    
    private func getLastWorkoutWithin24Hours() -> WorkoutHistoryItem? {
        let now = Date()
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now) ?? now
        
        return healthKitManager.workoutHistory.first { workout in
            workout.date >= twentyFourHoursAgo
        }
    }
}

struct RecentWorkoutCardView: View {
    let workout: WorkoutHistoryItem
    let speechManager: ElevenLabsManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    var body: some View {
        Button(action: {
            let workoutData = WorkoutData(
                duration: workout.duration,
                distance: workout.distance,
                heartRate: workout.heartRate,
                calories: workout.calories,
                workoutType: workout.workoutType
            )
            
            let roast = RoastGenerator.generateRoast(
                stepCount: 0,
                heartRate: workout.heartRate,
                sleepHours: 0,
                workoutData: workoutData,
                character: characterViewModel.selectedCharacter
            )
            
            speechManager.speakRoast(roast)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Workout type and date header
                HStack {
                    Image(systemName: workoutTypeIcon(workout.workoutType))
                        .font(.title3)
                        .foregroundColor(workoutTypeColor(workout.workoutType))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.workoutType)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(formatWorkoutDate(workout.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if speechManager.isSpeaking {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Key metrics
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        MetricPill(
                            value: "\(Int(workout.duration / 60))m",
                            label: "Duration",
                            color: .blue
                        )
                        
                        MetricPill(
                            value: "\(Int(workout.calories))",
                            label: "Calories",
                            color: .orange
                        )
                    }
                    
                    HStack(spacing: 16) {
                        if workout.distance > 0 {
                            MetricPill(
                                value: String(format: "%.1f mi", workout.distance),
                                label: "Distance",
                                color: .green
                            )
                        }
                        
                        if workout.heartRate > 0 {
                            MetricPill(
                                value: "\(Int(workout.heartRate)) BPM",
                                label: "Avg HR",
                                color: .red
                            )
                        }
                    }
                }
                
                // Performance indicators
                HStack {
                    ForEach(getPerformanceIndicators(), id: \.self) { indicator in
                        Text(indicator)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .frame(width: 220)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(workoutTypeColor(workout.workoutType).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getPerformanceIndicators() -> [String] {
        var indicators: [String] = []
        
        // Duration indicators
        if workout.duration < 600 { // Less than 10 minutes
            indicators.append("Short")
        } else if workout.duration < 1200 { // Less than 20 minutes
            indicators.append("Brief")
        }
        
        // Calorie indicators
        if workout.calories < 100 {
            indicators.append("Low Cal")
        }
        
        // Heart rate indicators
        if workout.heartRate > 0 && workout.heartRate < 120 {
            indicators.append("Easy")
        } else if workout.heartRate > 160 {
            indicators.append("Intense")
        }
        
        // Pace indicators (for running/walking)
        if workout.distance > 0 && (workout.workoutType.contains("Running") || workout.workoutType.contains("Walking")) {
            let pace = workout.duration / (workout.distance * 60) // minutes per mile
            if pace > 12 {
                indicators.append("Slow")
            } else if pace < 7 {
                indicators.append("Fast")
            }
        }
        
        return Array(indicators.prefix(2)) // Limit to 2 indicators
    }
    
    private func formatWorkoutDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func workoutTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "running": return "figure.run"
        case "walking": return "figure.walk"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "yoga": return "figure.mind.and.body"
        case "strength training", "functional training": return "dumbbell"
        case "core training": return "figure.core.training"
        default: return "figure.mixed.cardio"
        }
    }
    
    private func workoutTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "running": return .green
        case "walking": return .blue
        case "cycling": return .orange
        case "swimming": return .cyan
        case "yoga": return .purple
        case "strength training", "functional training": return .red
        case "core training": return .pink
        default: return .gray
        }
    }
}

struct MetricPill: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.2))
        )
    }
}
