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
    @ObservedObject var speechManager = ElevenLabsManager.shared
    @State private var selectedPersona = "🔥"
    @State private var showFullHistory = false
    @State private var showPaywall = false
    @State private var emberTimer: Timer?
    
    private let personas = [
        ("🔥", "Savage", "No mercy mode"),
        ("😈", "Brutal", "Maximum damage"),
        ("💀", "Ruthless", "Emotional destruction"),
        ("🤡", "Sarcastic", "Witty roasts")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
              
            // Ember/spark animation overlay - positioned above all content, covering full screen
            EmberOverlayView()

            ScrollView {
                VStack(spacing: 0) {
                    // New Hero Section with Shame Score Arc at top
                    VStack(spacing: 0) {
                        // Shame Score Header and Arc
                        VStack(spacing: 20) {
                            Text("YOUR FITNESS SHAME SCORE")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                                .tracking(2)
                                .padding(.top, 40)
                            
                            // Shame Score Arc (semi-circle like speedometer)
                            ZStack {
                                // Background Arc (speedometer shape - empty at bottom center)
                                Circle()
                                    .trim(from: 0.3, to: 1.2)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 16)
                                    .frame(width: 280, height: 280)
                                    .rotationEffect(.degrees(35))
                                
                                // Progress Arc
                                Circle()
                                    .trim(from: 0.3, to: 0.3 + (CGFloat(calculateShameScore()) / 100) * 0.9)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .orange, .yellow]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                    )
                                    .frame(width: 280, height: 280)
                                    .rotationEffect(.degrees(35))
                                    .animation(.easeInOut(duration: 1.5), value: calculateShameScore())
                                
                                // Score Display in center
                                VStack(spacing: 8) {
                                    Text("\(Int(calculateShameScore()))%")
                                        .font(.system(size: 72, weight: .black, design: .rounded))
                                        .foregroundColor(.orange)
                                    
                                    Text(getShameScoreLabel())
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .tracking(1)
                                }
                                .offset(y: 20)
                            }
                        }
                        
                        // Character Section with full-body image and gradient background
                        if let character = characterViewModel.selectedCharacter {
                            ZStack {
                                // Gradient background behind character (like explore page)
                                RadialGradient(
                                    gradient: gradientForCharacter(character.name),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                                .frame(height: 400)
                                
                                // Character image (full body, not clipped to circle)
                                Image(character.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 350)
                                    .clipped()
                                 
                                
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.clear, Color.clear, Color.black.opacity(0.8), Color.black, Color.black]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(height: 120)
                                }
                            }
                            .frame(height: 400)
                            .offset(y: -60) // Move character up to overlap with arc
                        }
                        
                        // Speech Bubble for Roast
                        VStack(spacing: 0) {
                            // Speech bubble
                            VStack(alignment: .leading, spacing: 12) {
                                Text(getCurrentRoastText())
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6).opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.orange, .red]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .padding(.horizontal, 20)
                            .offset(y: -80) // Move bubble up to be closer to character
                            
                            // Speech bubble pointer (triangle pointing up to character)
                            Triangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 20, height: 12)
                                .offset(y: -92) // Position triangle to connect with bubble
                        }
                        
                        // HEAR TODAY'S ROAST Button
                        Button(action: {
                            print("🔥 HEAR TODAY'S ROAST button pressed")
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
                            HStack(spacing: 12) {
                                if speechManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "headphones")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                
                                Text("HEAR TODAY'S ROAST")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.orange, .red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .scaleEffect(speechManager.isSpeaking ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: speechManager.isSpeaking)
                        }
                        .disabled(speechManager.isSpeaking || speechManager.isLoading)
                        .padding(.horizontal, 20)
                        .offset(y: -60) // Move button up to be closer to speech bubble
                    }
                    .padding(.bottom, 30) // Add some spacing after hero section
                    
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
                            value: "\(Int(healthKitManager.dailyCalories))",
                            color: .orange,
                            icon: "flame.fill"
                        ) {
                            speechManager.canGenerateRoast { canGenerate in
                                if !canGenerate {
                                    showPaywall = true
                                    return
                                }
                                let roast = RoastGenerator.generateCalorieRoast(calories: healthKitManager.dailyCalories, character: characterViewModel.selectedCharacter)
                                speechManager.speakRoast(roast)
                            }
                        }
                        
                        // Exercise Time Block
                        StatBlockView(
                            title: "EXERCISE TIME",
                            value: formatExerciseTime(healthKitManager.exerciseMinutes),
                            color: .green,
                            icon: "timer"
                        ) {
                            speechManager.canGenerateRoast { canGenerate in
                                if !canGenerate {
                                    showPaywall = true
                                    return
                                }
                                let roast = RoastGenerator.generateDurationRoast(duration: healthKitManager.exerciseMinutes * 60, character: characterViewModel.selectedCharacter)
                                speechManager.speakRoast(roast)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
//                    // Burn Me Again Button
//                    Button(action: {
//                        speechManager.canGenerateRoast { canGenerate in
//                            if !canGenerate {
//                                showPaywall = true
//                                return
//                            }
//                            let roast = RoastGenerator.generateRoast(
//                                stepCount: healthKitManager.stepCount,
//                                heartRate: healthKitManager.heartRate,
//                                sleepHours: healthKitManager.sleepHours,
//                                workoutData: healthKitManager.latestWorkout,
//                                character: characterViewModel.selectedCharacter
//                            )
//                            speechManager.speakRoast(roast)
//                        }
//                    }) {
//                        HStack(spacing: 12) {
//                            if speechManager.isLoading {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
//                                    .scaleEffect(0.8)
//                            } else {
//                                Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "flame.fill")
//                                    .font(.title2)
//                                    .foregroundColor(.black)
//                            }
//                            
//                            Text("BURN ME AGAIN")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .foregroundColor(.black)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 20)
//                        .background(
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(LinearGradient(
//                                    gradient: Gradient(colors: [.orange, .red]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                ))
//                        )
//                        .scaleEffect(speechManager.isSpeaking ? 0.95 : 1.0)
//                        .animation(.easeInOut(duration: 0.1), value: speechManager.isSpeaking)
//                    }
//                    .disabled(speechManager.isSpeaking || speechManager.isLoading)
//                    .padding(.horizontal, 20)
                    
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
        .presentPaywallIfNeeded { customerInfo in
            // Returning `true` will present the paywall - show if NOT subscribed
            return !customerInfo.entitlements.active.keys.contains("premium")
        } purchaseCompleted: { customerInfo in
            print("Purchase completed: \(customerInfo.entitlements)")
        } restoreCompleted: { customerInfo in
            // Paywall will be dismissed automatically if "pro" is now active.
            print("Purchases restored: \(customerInfo.entitlements)")
        }
        .onAppear {
            healthKitManager.fetchTodaysData()
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
}

// MARK: - Triangle Shape for Speech Bubble Pointer
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct RecentWorkoutCardView: View {
    let workout: WorkoutHistoryItem
    let speechManager: ElevenLabsManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    var body: some View {
        Button(action: {
            let workoutData = WorkoutData(
                startDate: workout.date,
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

// MARK: - Ember Overlay View
struct EmberOverlayView: View {
    @State private var embers: [Ember] = []
    private let emberCount = 15
    
    init() {
        _embers = State(initialValue: Self.generateInitialEmbers())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(embers.indices, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.9),
                                    Color.red.opacity(0.7),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 3
                            )
                        )
                        .frame(width: embers[index].size, height: embers[index].size)
                        .position(
                            x: embers[index].x,
                            y: embers[index].y
                        )
                        .opacity(embers[index].opacity)
                        .animation(
                            .linear(duration: embers[index].duration),
                            value: embers[index].progress
                        )
                        .onAppear {
                            startEmberAnimation(index: index, in: geometry)
                        }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false) // Allow touches to pass through to underlying content
    }
    
    private static func generateInitialEmbers() -> [Ember] {
        return (0..<15).map { _ in
            Ember(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: UIScreen.main.bounds.height + CGFloat.random(in: 0...100),
                size: CGFloat.random(in: 2...5),
                opacity: Double.random(in: 0.4...0.8),
                duration: Double.random(in: 4...8),
                progress: 0,
                horizontalDrift: CGFloat.random(in: -30...30)
            )
        }
    }
    
    private func startEmberAnimation(index: Int, in geometry: GeometryProxy) {
        guard index < embers.count else { return }
        
        // Reset ember position
        embers[index].y = geometry.size.height + CGFloat.random(in: 0...100)
        embers[index].x = CGFloat.random(in: 0...geometry.size.width)
        embers[index].progress = 0
        
        // Animate upward movement
        withAnimation(
            .linear(duration: embers[index].duration)
        ) {
            embers[index].progress = 1.0
            embers[index].y = -50 // Move to top of screen
            embers[index].x += embers[index].horizontalDrift // Add horizontal drift
            embers[index].opacity = 0 // Fade out at top
        }
        
        // Reset ember after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + embers[index].duration) {
            resetEmber(index: index, in: geometry)
        }
    }
    
    private func resetEmber(index: Int, in geometry: GeometryProxy) {
        guard index < embers.count else { return }
        
        // Create new ember at bottom
        embers[index] = Ember(
            x: CGFloat.random(in: 0...geometry.size.width),
            y: geometry.size.height + CGFloat.random(in: 0...100),
            size: CGFloat.random(in: 2...5),
            opacity: Double.random(in: 0.4...0.8),
            duration: Double.random(in: 4...8),
            progress: 0,
            horizontalDrift: CGFloat.random(in: -30...30)
        )
        
        // Start new animation
        startEmberAnimation(index: index, in: geometry)
    }
}

// MARK: - Ember Data Model
struct Ember {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var duration: Double
    var progress: Double
    var horizontalDrift: CGFloat
}
