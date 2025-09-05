//
//  HomeTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI
import HealthKit
import RevenueCat
import RevenueCatUI

struct HomeTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @ObservedObject private var speechManager = ElevenLabsManager.shared
    @State private var selectedPersona = "🔥"
    @State private var showFullHistory = false
    @State private var showPaywall = false
    
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
                VStack(spacing: 30) {
                    // Hero Section: Fitness Shame Score + Character Status
                    VStack(spacing: 25) {
                        // Character Status Display
                        if let character = characterViewModel.selectedCharacter {
                            HStack(spacing: 15) {
                                // Character Avatar with Image
                                ZStack {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(character.imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(getCharacterMoodStroke(), lineWidth: 3)
                                                )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(character.name.uppercased())
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 5) {
                                        Text(getCharacterMoodEmoji())
                                            .font(.title2)
                                        
                                        Text(getCharacterMoodText())
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        VStack(spacing: 15) {
                            Text("FITNESS SHAME SCORE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            ZStack {
                                // Background Circle
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                                    .frame(width: 200, height: 200)
                                
                                // Progress Circle
                                Circle()
                                    .trim(from: 0, to: CGFloat(calculateShameScore()) / 100)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: getShameScoreGradient()),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1.0), value: calculateShameScore())
                                
                                // Score Display
                                VStack(spacing: 5) {
                                    Text("\(Int(calculateShameScore()))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(getShameScoreLabel())
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // Quick Action Buttons
                        HStack(spacing: 12) {
                            // Get Roasted Button
                            Button(action: {
                                print("🔥 GET ROASTED button pressed")
                                print("📊 Step count: \(healthKitManager.stepCount)")
                                print("❤️ Heart rate: \(healthKitManager.heartRate)")
                                print("😴 Sleep hours: \(healthKitManager.sleepHours)")
                                print("💪 Latest workout: \(String(describing: healthKitManager.latestWorkout))")
                                print("🎭 Selected character: \(String(describing: characterViewModel.selectedCharacter?.name))")
                                
                                // Check if user can generate roast asynchronously
                                print("🔍 Checking if user can generate roast...")
                                speechManager.canGenerateRoast { canGenerate in
                                    print("✅ Can generate roast: \(canGenerate)")
                                    print("📈 Daily roast count: \(speechManager.dailyRoastCount)")
                                    
                                    if !canGenerate {
                                        print("🚫 Daily limit exceeded - showing paywall")
                                        showPaywall = true
                                        return
                                    }
                                    
                                    print("🎯 Generating roast...")
                                    let roast = RoastGenerator.generateRoast(
                                        stepCount: healthKitManager.stepCount,
                                        heartRate: healthKitManager.heartRate,
                                        sleepHours: healthKitManager.sleepHours,
                                        workoutData: healthKitManager.latestWorkout,
                                        character: characterViewModel.selectedCharacter
                                    )
                                    print("📝 Generated roast: \(roast)")
                                    
                                    print("🗣️ Speaking roast...")
                                    speechManager.speakRoast(roast)
                                }
                            }) {
                                VStack(spacing: 8) {
                                    if speechManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "flame.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    Text("GET ROASTED")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 120, height: 80)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .red]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            .disabled(speechManager.isSpeaking || speechManager.isLoading)
                            
                            // Quick Improvement Button
                            Button(action: {
                                triggerQuickImprovement()
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "figure.run")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    Text("IMPROVE NOW")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .frame(width: 120, height: 80)
                                .background(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
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
                            speechManager.canGenerateRoast { canGenerate in
                                if !canGenerate {
                                    showPaywall = true
                                    return
                                }
                                let roast = RoastGenerator.generateStepRoast(stepCount: healthKitManager.stepCount, character: characterViewModel.selectedCharacter)
                                speechManager.speakRoast(roast)
                            }
                        }
                        
                        // Calories Block
                        StatBlockView(
                            title: "CALORIES",
                            value: "\(Int(healthKitManager.latestWorkout?.calories ?? 0))",
                            color: .orange,
                            icon: "flame.fill"
                        ) {
                            speechManager.canGenerateRoast { canGenerate in
                                if !canGenerate {
                                    showPaywall = true
                                    return
                                }
                                let roast = RoastGenerator.generateCalorieRoast(calories: healthKitManager.latestWorkout?.calories ?? 0, character: characterViewModel.selectedCharacter)
                                speechManager.speakRoast(roast)
                            }
                        }
                        
                        // Workout Time Block
                        StatBlockView(
                            title: "WORKOUT TIME",
                            value: formatDuration(healthKitManager.latestWorkout?.duration ?? 0),
                            color: .green,
                            icon: "timer"
                        ) {
                            speechManager.canGenerateRoast { canGenerate in
                                if !canGenerate {
                                    showPaywall = true
                                    return
                                }
                                let roast = RoastGenerator.generateDurationRoast(duration: healthKitManager.latestWorkout?.duration ?? 0, character: characterViewModel.selectedCharacter)
                                speechManager.speakRoast(roast)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Burn Me Again Button
                    Button(action: {
                        speechManager.canGenerateRoast { canGenerate in
                            if !canGenerate {
                                showPaywall = true
                                return
                            }
                            let roast = RoastGenerator.generateRoast(
                                stepCount: healthKitManager.stepCount,
                                heartRate: healthKitManager.heartRate,
                                sleepHours: healthKitManager.sleepHours,
                                workoutData: healthKitManager.latestWorkout,
                                character: characterViewModel.selectedCharacter
                            )
                            speechManager.speakRoast(roast)
                        }
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
                            Button("History") {
                                showFullHistory = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
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
                            VStack(spacing: 12) {
                                ForEach(Array(healthKitManager.workoutHistory.prefix(5).enumerated()), id: \.offset) { index, workout in
                                    RecentWorkoutCardView(
                                        workout: workout,
                                        speechManager: speechManager
                                    )
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        // Remove auto-presenting paywall - only show when user triggers actions
        .onAppear {
            healthKitManager.fetchWorkoutHistory()
            
        }
        .sheet(isPresented: $showFullHistory) {
            WorkoutHistoryView()
                .environmentObject(healthKitManager)
                .environmentObject(characterViewModel)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
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
    
    // MARK: - Fitness Shame Score Functions
    private func calculateShameScore() -> Double {
        let stepScore = min(Double(healthKitManager.stepCount) / 10000.0, 1.0) * 30 // 30% weight
        let workoutScore = (healthKitManager.latestWorkout?.duration ?? 0) > 0 ? 25.0 : 0 // 25% weight
        let calorieScore = min((healthKitManager.latestWorkout?.calories ?? 0) / 300.0, 1.0) * 20 // 20% weight
        let consistencyScore = healthKitManager.workoutHistory.count > 0 ? 25.0 : 0 // 25% weight
        
        let totalScore = stepScore + workoutScore + calorieScore + consistencyScore
        return 100 - totalScore // Invert to make it a "shame" score
    }
    
    private func getShameScoreGradient() -> [Color] {
        let score = calculateShameScore()
        switch score {
        case 0...30: return [.green, .mint] // Great performance
        case 31...50: return [.yellow, .orange] // Average performance  
        case 51...75: return [.orange, .red] // Poor performance
        default: return [.red, .purple] // Shameful performance
        }
    }
    
    private func getShameScoreLabel() -> String {
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
    private func getCharacterMoodStroke() -> Color {
        let score = calculateShameScore()
        switch score {
        case 0...30: return .green
        case 31...50: return .yellow  
        case 51...75: return .orange
        default: return .red
        }
    }
    
    private func getCharacterMoodEmoji() -> String {
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
    
    private func getCharacterMoodText() -> String {
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
    
    // MARK: - Quick Improvement Function
    private func triggerQuickImprovement() {
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
            HStack(spacing: 16) {
                // Workout type icon in colored circle
                ZStack {
                    Circle()
                        .fill(workoutTypeColor(workout.workoutType).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: workoutTypeIcon(workout.workoutType))
                        .font(.title2)
                        .foregroundColor(workoutTypeColor(workout.workoutType))
                }
                
                // Workout details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayWorkoutType(workout.workoutType))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(formatWorkoutDateForCard(workout.date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Main metrics line
                    HStack(spacing: 4) {
                        Text("\(Int(workout.duration / 60)) min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(Int(workout.calories)) kcal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if workout.distance > 0 {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(String(format: "%.1f km", workout.distance * 1.60934))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // Performance indicator pill at bottom
                    HStack {
                        if let indicator = self.getPerformanceIndicator() {
                            Text(indicator.text)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(indicator.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(indicator.color.opacity(0.15))
                                )
                        }
                        
                        Spacer()
                        
                        if speechManager.isSpeaking {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getPerformanceIndicator() -> (text: String, color: Color)? {
        // Duration-based indicators (highest priority)
        if workout.duration < 600 { // Less than 10 minutes
            return ("Short", .orange)
        } else if workout.duration > 3600 { // More than 1 hour
            return ("Long", .green)
        }
        
        // Calorie-based indicators
        if workout.calories < 100 {
            return ("Low Cal", .red)
        } else if workout.calories > 500 {
            return ("High Cal", .green)
        }
        
        // Heart rate indicators
        if workout.heartRate > 0 {
            if workout.heartRate < 120 {
                return ("Easy", .blue)
            } else if workout.heartRate > 160 {
                return ("Intense", .red)
            }
        }
        
        // Pace indicators (for running/walking)
        if workout.distance > 0 && (workout.workoutType.contains("Running") || workout.workoutType.contains("Walking")) {
            let pace = workout.duration / (workout.distance * 60) // minutes per mile
            if pace > 12 {
                return ("Slow", .orange)
            } else if pace < 7 {
                return ("Fast", .green)
            }
        }
        
        return nil
    }
    
    private func displayWorkoutType(_ type: String) -> String {
        // Handle "Unknown" workouts that are likely sprint screening
        if type.lowercased().contains("unknown") || type == "Unknown" {
            return "Strength Training"
        }
        return type
    }
    
    private func formatWorkoutDateForCard(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            return "Yesterday"
        } else {
            let daysDiff = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            if daysDiff < 7 {
                return "\(daysDiff)d ago"
            } else {
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
        }
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

struct WorkoutHistoryView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @ObservedObject private var speechManager = ElevenLabsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if healthKitManager.workoutHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No workouts found")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Text("Start working out to build your history!")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(healthKitManager.workoutHistory) { workout in
                                WorkoutHistoryRow(
                                    workout: workout,
                                    speechManager: speechManager
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct WorkoutHistoryRow: View {
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
            HStack(spacing: 16) {
                // Workout type icon in colored circle
                ZStack {
                    Circle()
                        .fill(workoutTypeColor(workout.workoutType).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: workoutTypeIcon(workout.workoutType))
                        .font(.title2)
                        .foregroundColor(workoutTypeColor(workout.workoutType))
                }
                
                // Workout details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayWorkoutType(workout.workoutType))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(formatWorkoutDate(workout.date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Main metrics line
                    HStack(spacing: 4) {
                        Text("\(Int(workout.duration / 60)) min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(Int(workout.calories)) kcal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if workout.distance > 0 {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(String(format: "%.1f km", workout.distance * 1.60934))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // Performance indicator pill at bottom
                    HStack {
                        if let indicator = getPerformanceIndicator() {
                            Text(indicator.text)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(indicator.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(indicator.color.opacity(0.15))
                                )
                        }
                        
                        Spacer()
                        
                        if speechManager.isSpeaking {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getPerformanceIndicator() -> (text: String, color: Color)? {
        // Duration-based indicators (highest priority)
        if workout.duration < 600 { // Less than 10 minutes
            return ("Short", .orange)
        } else if workout.duration > 3600 { // More than 1 hour
            return ("Long", .green)
        }
        
        // Calorie-based indicators
        if workout.calories < 100 {
            return ("Low Cal", .red)
        } else if workout.calories > 500 {
            return ("High Cal", .green)
        }
        
        // Heart rate indicators
        if workout.heartRate > 0 {
            if workout.heartRate < 120 {
                return ("Easy", .blue)
            } else if workout.heartRate > 160 {
                return ("Intense", .red)
            }
        }
        
        // Pace indicators (for running/walking)
        if workout.distance > 0 && (workout.workoutType.contains("Running") || workout.workoutType.contains("Walking")) {
            let pace = workout.duration / (workout.distance * 60) // minutes per mile
            if pace > 12 {
                return ("Slow", .orange)
            } else if pace < 7 {
                return ("Fast", .green)
            }
        }
        
        return nil
    }
    
    private func displayWorkoutType(_ type: String) -> String {
        // Handle "Unknown" workouts that are likely sprint screening
        if type.lowercased().contains("unknown") || type == "Unknown" {
            return "Strength Training"
        }
        return type
    }
    
    private func workoutTypeIcon(_ type: String) -> String {
        let displayType = displayWorkoutType(type)
        switch displayType.lowercased() {
        case "sprint screening": return "timer"
        case "running": return "figure.run"
        case "walking": return "figure.walk"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "yoga": return "figure.mind.and.body"
        case "strength training", "functional training": return "dumbbell"
        case "core training": return "figure.core.training"
        case "stair climbing machine": return "figure.stairs"
        default: return "figure.mixed.cardio"
        }
    }
    
    private func workoutTypeColor(_ type: String) -> Color {
        let displayType = displayWorkoutType(type)
        switch displayType.lowercased() {
        case "sprint screening": return .purple
        case "running": return .green
        case "walking": return .blue
        case "cycling": return .orange
        case "swimming": return .cyan
        case "yoga": return .purple
        case "strength training", "functional training": return .red
        case "core training": return .pink
        case "stair climbing machine": return .indigo
        default: return .gray
        }
    }
    
    private func formatWorkoutDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            return "Yesterday"
        } else {
            let daysDiff = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            if daysDiff < 7 {
                return "\(daysDiff)d ago"
            } else {
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
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
