//
//  ContentView.swift
//  Burned
//
//  Created by Raghav Sethi on 11/08/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            HeartRateTab()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Heart Rate")
                }
            
            DurationTab()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Duration")
                }
            
            PaceTab()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Pace")
                }
            
            CaloriesTab()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Calories")
                }
            
            ConsistencyTab()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Consistency")
                }
            
            TestTab()
                .tabItem {
                    Image(systemName: "bell.badge")
                    Text("Test")
                }
        }
        .onAppear {
            healthKitManager.requestAuthorization()
        }
    }
}

struct HeartRateTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    private let heartRateRoasts = [
        "Congrats, your heart rate says you're basically asleep.",
        "That's not cardio, that's just walking while stressed.",
        "If your heart beat any slower, I'd have to check for a pulse.",
        "You call this intense? My grandma spikes higher climbing stairs.",
        "Your heart rate is flatlining harder than your motivation.",
        "Even meditation gets your heart pumping more than that.",
        "Your fitness tracker thinks it's malfunctioned.",
        "Your pulse is slower than government bureaucracy.",
        "Even my notification sounds have more rhythm than your heart.",
        "Meditation apps are using you as their success story."
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Current Heart Rate")
                        .font(.headline)
                    Text("\(Int(healthKitManager.heartRate)) BPM")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                List(heartRateRoasts, id: \.self) { roast in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(roast)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .navigationTitle("❤️ Heart Rate Roasts")
        }
    }
}

struct DurationTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    private let durationRoasts = [
        "12 minutes? That's… adorable.",
        "Your workout was so short, even Netflix trailers last longer.",
        "Did you actually work out or just walk to the fridge?",
        "Blink and it's over. Oh wait, it was over.",
        "That wasn't a workout, that was a commercial break.",
        "Even TikTok videos have more commitment than this.",
        "Your workout timer is confused — did you even start?",
        "That's not a workout, that's a bathroom break with extra steps.",
        "Even my screen timeout lasts longer than your workout."
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Last Workout Duration")
                        .font(.headline)
                    Text(formatDuration(healthKitManager.latestWorkout?.duration ?? 0))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                List(durationRoasts, id: \.self) { roast in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(roast)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .navigationTitle("⏱️ Duration Roasts")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}

struct PaceTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    private let paceRoasts = [
        "Snails are filing harassment complaints for being compared to you.",
        "If this were a race, you'd still be tying your shoes.",
        "Even your shadow's bored waiting for you.",
        "Google Maps recalculated — you're officially walking backwards.",
        "Turtles called - they want their pace back.",
        "At this speed, you'll finish your marathon in… never.",
        "Paint dries faster than you run.",
        "Are you running or doing interpretive dance in slow motion?",
        "My grandmother's power walk is faster than your 'run'."
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Average Pace")
                        .font(.headline)
                    if let workout = healthKitManager.latestWorkout, workout.distance > 0 {
                        let pace = workout.duration / (workout.distance * 60)
                        Text("\(String(format: "%.1f", pace)) min/mile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("No Data")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                List(paceRoasts, id: \.self) { roast in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(roast)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .navigationTitle("🏃 Pace Roasts")
        }
    }
}

struct CaloriesTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    private let calorieRoasts = [
        "Wow, enough calories burned to almost offset a cookie.",
        "All that effort for half a samosa? Bold move.",
        "You burned 100 calories… hope that sip of soda was worth it.",
        "Basically zero emissions. You're like the Prius of people.",
        "That calorie burn couldn't power a night light.",
        "You've burned more calories thinking about working out.",
        "Even breathing burns more calories than that 'workout'.",
        "You burned fewer calories than a birthday candle.",
        "That calorie burn couldn't power a calculator."
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Calories Burned")
                        .font(.headline)
                    Text("\(Int(healthKitManager.latestWorkout?.calories ?? 0)) cal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                List(calorieRoasts, id: \.self) { roast in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(roast)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .navigationTitle("🔥 Calorie Roasts")
        }
    }
}

struct ConsistencyTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    private let consistencyRoasts = [
        "Step count so low I thought your phone was charging all day.",
        "You've taken more screenshots than steps today.",
        "Wow. You're single-handedly keeping the couch industry alive.",
        "Fitbit would've just given up on you by now.",
        "Your step counter is having an existential crisis.",
        "Even statues move more than you do.",
        "Your daily steps wouldn't even cover a grocery store aisle.",
        "Houseplants are getting more exercise than you.",
        "No workout today? Your potential called — it's filing a missing person report.",
        "Rest day #47? Even your excuses need a workout at this point."
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Daily Steps")
                        .font(.headline)
                    Text("\(healthKitManager.stepCount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                List(consistencyRoasts, id: \.self) { roast in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(roast)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .navigationTitle("📊 Consistency Roasts")
        }
    }
}

struct HomeTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @StateObject private var speechManager = ElevenLabsManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with current stats
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today's Stats")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("\(healthKitManager.stepCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    Text("Steps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack {
                                    Text("\(Int(healthKitManager.heartRate))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    Text("BPM")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let workout = healthKitManager.latestWorkout {
                                    VStack {
                                        Text("\(Int(workout.calories))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                        Text("Calories")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        Spacer()
                        
                        Button(action: {
                            let roast = healthKitManager.getCurrentRoast()
                            speechManager.speakRoast(roast)
                        }) {
                            VStack {
                                if speechManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "speaker.2.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                Text("Roast Me")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.orange, .red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(speechManager.isSpeaking || speechManager.isLoading)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Workout History List
                if healthKitManager.workoutHistory.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "figure.run")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No workouts found")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text("Start working out to get roasted!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                } else {
                    List(healthKitManager.workoutHistory) { workout in
                        WorkoutRowView(workout: workout, speechManager: speechManager)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("🔥 Burned")
            .onAppear {
                healthKitManager.fetchWorkoutHistory()
            }
        }
    }
}

struct WorkoutRowView: View {
    let workout: WorkoutHistoryItem
    let speechManager: ElevenLabsManager
    @State private var isPressed = false
    
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
                stepCount: 0, // Not relevant for specific workout
                heartRate: workout.heartRate,
                sleepHours: 0, // Not relevant for specific workout
                workoutData: workoutData
            )
            
            speechManager.speakRoast(roast)
        }) {
            HStack(spacing: 12) {
                // Workout type icon
                VStack {
                    Image(systemName: workoutTypeIcon(workout.workoutType))
                        .font(.title2)
                        .foregroundColor(workoutTypeColor(workout.workoutType))
                        .frame(width: 40, height: 40)
                        .background(workoutTypeColor(workout.workoutType).opacity(0.1))
                        .cornerRadius(8)
                    
                    if speechManager.isSpeaking || speechManager.isLoading {
                        Image(systemName: speechManager.isLoading ? "arrow.down.circle.fill" : "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .animation(.easeInOut(duration: 0.3), value: speechManager.isLoading)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(workout.workoutType)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(workout.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        Label(workout.formattedDuration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if workout.distance > 0 {
                            Label(String(format: "%.1f mi", workout.distance), systemImage: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if workout.calories > 0 {
                            Label("\(Int(workout.calories)) cal", systemImage: "flame")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Performance indicators
                    HStack(spacing: 8) {
                        if workout.duration < 600 {
                            performanceTag("Short", .orange)
                        }
                        if workout.heartRate > 0 && workout.heartRate < 100 {
                            performanceTag("Low HR", .blue)
                        }
                        if workout.calories < 150 {
                            performanceTag("Low Cal", .red)
                        }
                        Spacer()
                        
                        Text("Tap to Roast")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private func performanceTag(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(4)
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

struct TestTab: View {
    @State private var lastNotificationTime = ""
    @State private var notificationStatus = "Tap button to test"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Test Notifications")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tap the button below to receive a random roast notification instantly!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Text(notificationStatus)
                        .font(.caption)
                        .foregroundColor(notificationStatus.contains("Error") ? .red : .blue)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    // OneSignal Test Button
                    Button(action: {
                        OneSignalManager.shared.sendTestRoast()
                        lastNotificationTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                        notificationStatus = "OneSignal test sent! (Check backend logs)"
                    }) {
                        HStack {
                            Image(systemName: "cloud.fill")
                            Text("Send OneSignal Test")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Local Notification Test Button (Backup)
                    Button(action: {
                        checkNotificationPermissionAndSend()
                        lastNotificationTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                    }) {
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("Send Test Roast")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    if !lastNotificationTime.isEmpty {
                        Text("Last test sent at \(lastNotificationTime)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sample Test Roasts:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach([
                                "Your motivation is currently under construction... indefinitely.",
                                "Even your excuses are getting lazy at this point.",
                                "Your workout schedule is more mythical than unicorns.",
                                "If procrastination burned calories, you'd be dangerously underweight.",
                                "Even your smartwatch is questioning its life choices.",
                                "Your couch has Stockholm syndrome at this point."
                            ], id: \.self) { roast in
                                HStack {
                                    Text("🔥")
                                    Text(roast)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("🧪 Test Notifications")
        }
    }
    
    private func checkNotificationPermissionAndSend() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    self.notificationStatus = "Permission granted! Sending notification..."
                    NotificationManager.shared.sendTestNotification()
                    
                    // Check if app is in background
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if UIApplication.shared.applicationState == .active {
                            self.notificationStatus = "⚠️ App is in foreground. Background the app to see notification!"
                        } else {
                            self.notificationStatus = "Notification sent!"
                        }
                    }
                case .denied:
                    self.notificationStatus = "Error: Notifications denied. Go to Settings > Burned > Notifications"
                case .notDetermined:
                    self.notificationStatus = "Requesting permission..."
                    NotificationManager.shared.requestPermission()
                case .provisional:
                    self.notificationStatus = "Permission granted! Sending notification..."
                    NotificationManager.shared.sendTestNotification()
                @unknown default:
                    self.notificationStatus = "Unknown permission status"
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
}
