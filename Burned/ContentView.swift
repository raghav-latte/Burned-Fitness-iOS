//
//  ContentView.swift
//  Burned
//
//  Created by Raghav Sethi on 11/08/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    var body: some View {
        ZStack {
            TabView {
            HomeTab()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ExploreTab()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Explore")
                }
            
            SettingsTab()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
            
            SummaryTab()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Summary")
                }
        }
        .accentColor(.orange)
        .onAppear {
            healthKitManager.requestAuthorization()
            configureTabBarAppearance()
        }
            
            // Character selection overlay
            if characterViewModel.selectedCharacter == nil || characterViewModel.showCharacterSelection {
                CharacterSelectionView(selectedCharacter: Binding(
                    get: { characterViewModel.selectedCharacter },
                    set: { character in
                        if let character = character {
                            characterViewModel.selectCharacter(character)
                        }
                    }
                ))
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemOrange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemOrange
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct ExploreTab: View {
    @State private var selectedCharacterIndex = 0
    @StateObject private var speechManager = ElevenLabsManager.shared
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    private let characters = Character.allCharacters
    
    private let challenges = [
        "Survive 30 days without excuses",
        "Beat your laziest week record",
        "Burn more calories than you make excuses",
        "Take more steps than selfies"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Character Card Deck Section
                    VStack(spacing: 20) {
                        Text("Choose Your Roaster")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        CharacterCardDeckView(
                            characters: characters,
                            selectedIndex: $selectedCharacterIndex,
                            speechManager: speechManager
                        ) { character in
                            characterViewModel.selectCharacter(character)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Challenges")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(challenges, id: \.self) { challenge in
                                    ChallengeCardView(challenge: challenge)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
}

struct CharacterCardDeckView: View {
    let characters: [Character]
    @Binding var selectedIndex: Int
    let speechManager: ElevenLabsManager
    let onCharacterSelect: (Character) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.8
            let cardHeight: CGFloat = 450
            
            ZStack {
                ForEach(Array(characters.enumerated().reversed()), id: \.offset) { index, character in
                    CharacterCardView(
                        character: character,
                        isSelected: selectedIndex == index,
                        speechManager: speechManager
                    ) {
                        onCharacterSelect(character)
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .scaleEffect(selectedIndex == index ? 1.0 : 0.9)
                    .opacity(1.0)  // Force full opacity for all cards
                    .offset(x: offsetForCard(at: index, cardWidth: cardWidth))
                    .zIndex(selectedIndex == index ? 1000 : Double(characters.count - index))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedIndex)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .frame(height: cardHeight)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold {
                            // Swipe right - previous card
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedIndex = max(0, selectedIndex - 1)
                            }
                        } else if value.translation.width < -threshold {
                            // Swipe left - next card
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedIndex = min(characters.count - 1, selectedIndex + 1)
                            }
                        }
                    }
            )
        }
        .frame(height: 450)
        .padding(.horizontal, 20)
    }
    
    private func offsetForCard(at index: Int, cardWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = cardWidth * 0.15
        let baseOffset = CGFloat(index - selectedIndex) * spacing
        
        if index == selectedIndex {
            return 0
        } else if index < selectedIndex {
            // Cards to the left - stack them behind
            return baseOffset - 20
        } else {
            // Cards to the right - show preview sliver
            return baseOffset + 20
        }
    }
}

struct CharacterCardView: View {
    let character: Character
    let isSelected: Bool
    let speechManager: ElevenLabsManager
    let onSelect: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: gradientForCharacter(character.name),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 0) {
                // Character Image Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 250)
                    
                    // Placeholder for character image
                    VStack {
                        Image(systemName: characterIcon(for: character.name))
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Image Placeholder")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Character Info Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.name.uppercased())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(character.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        // Arrow indicators (inspired by reference image)
                        if !isSelected {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Buttons row
                    HStack(spacing: 12) {
                        // Preview button
                        Button(action: {
                            let sampleRoast = getSampleRoast(for: character.name)
                            speechManager.speakRoast(sampleRoast)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: speechManager.isSpeaking ? "speaker.wave.2.fill" : "play.circle.fill")
                                    .font(.body)
                                Text("PREVIEW")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(speechManager.isSpeaking)
                        
                        // Set as Roaster button
                        Button(action: {
                            onSelect()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                Text("SET AS ROASTER")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .cornerRadius(20)
    }
    
    private func gradientForCharacter(_ name: String) -> Gradient {
        switch name {
        case "Drill Sergeant":
            return Gradient(colors: [Color.green, Color.black])
        case "British Narrator":
            return Gradient(colors: [Color.blue, Color.indigo])
        case "Your Ex":
            return Gradient(colors: [Color.purple, Color.pink])
        case "The Savage":
            return Gradient(colors: [Color.red, Color.orange])
        default:
            return Gradient(colors: [Color.gray, Color.black])
        }
    }
    
    private func characterIcon(for name: String) -> String {
        switch name {
        case "Drill Sergeant":
            return "shield.fill"
        case "British Narrator":
            return "mic.fill"
        case "Your Ex":
            return "heart.slash.fill"
        case "The Savage":
            return "flame.fill"
        default:
            return "person.fill"
        }
    }
    
    private func getSampleRoast(for characterName: String) -> String {
        switch characterName {
        case "Drill Sergeant":
            return "Drop and give me twenty! Your workout performance is more disappointing than a broken treadmill!"
        case "British Narrator":
            return "And here we observe the human in their natural habitat, avoiding exercise with the dedication of a professional couch potato."
        case "Your Ex":
            return "Still working out alone, I see. At least the gym equipment won't ghost you like I did."
        case "The Savage":
            return "Your fitness level is so low, even your shadow is embarrassed to follow you around."
        default:
            return "Time to get roasted!"
        }
    }
}

struct PersonalityCardView: View {
    let persona: (emoji: String, name: String, tagline: String, preview: String)
    let isSelected: Bool
    let speechManager: ElevenLabsManager
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: isSelected ? [.orange, .red] : [.gray.opacity(0.3), .gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(), value: isSelected)
                
                Text(persona.emoji)
                    .font(.system(size: 50))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(), value: isSelected)
            }
            
            VStack(spacing: 8) {
                Text(persona.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(persona.tagline)
                    .font(.caption)
                    .foregroundColor(isSelected ? .orange : .gray)
                    .fontWeight(.medium)
            }
            
            Button(action: {
                speechManager.speakRoast(persona.preview)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: speechManager.isSpeaking ? "speaker.wave.2.fill" : "play.fill")
                        .font(.caption)
                    Text("Preview")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .disabled(speechManager.isSpeaking)
        }
        .frame(width: 160)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            action()
        }
    }
}

struct ChallengeCardView: View {
    let challenge: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Text(challenge)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(width: 200)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
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

struct StatBlockView: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text("TAP TO ROAST")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(value)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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

struct SettingsTab: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @State private var roastIntensity: Double = 3.0
    @State private var notificationStyle: Int = 0
    @State private var autoPostToX: Bool = false
    @State private var reminderFrequency: Double = 4.0
    
    private let notificationStyles = ["Ping me when I'm lazy", "Humiliate me publicly"]
    private let intensityEmojis = ["🙂", "😐", "😬", "🔥", "💀"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Configure your destruction preferences")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 24) {
                        // Character Selection Card
                        NewSettingCardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Voice Character")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(characterViewModel.selectedCharacter?.name ?? "None Selected")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    characterViewModel.showCharacterSelection = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Change")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        NewSettingCardView {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Roast Intensity")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(intensityEmojis[min(Int(roastIntensity), intensityEmojis.count - 1)])
                                        .font(.title2)
                                }
                                
                                HStack {
                                    Text("Gentle")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Slider(value: $roastIntensity, in: 0...4, step: 1)
                                        .accentColor(.orange)
                                    
                                    Text("Savage")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        NewSettingCardView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Notification Style")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Notification Style", selection: $notificationStyle) {
                                    ForEach(Array(notificationStyles.enumerated()), id: \.offset) { index, style in
                                        Text(style)
                                            .foregroundColor(.white)
                                            .tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        
                        NewSettingCardView {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Reminder Frequency")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(reminderFrequency))h")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                
                                HStack {
                                    Text("1h")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Slider(value: $reminderFrequency, in: 1...12, step: 1)
                                        .accentColor(.orange)
                                    
                                    Text("12h")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        NewSettingCardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Auto-Post to X")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Share your shame automatically")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $autoPostToX)
                                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        Text("Burned is not responsible for hurt feelings.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Reset All Settings") {
                            withAnimation {
                                roastIntensity = 3.0
                                notificationStyle = 0
                                autoPostToX = false
                                reminderFrequency = 4.0
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
}

struct NewSettingCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct SummaryTab: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @StateObject private var speechManager = ElevenLabsManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("Daily Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your complete failure analysis")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 30) {
                        Text(generateDailySummaryRoast())
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6).opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 20) {
                            SummaryStatCard(
                                title: "Steps",
                                value: "\(healthKitManager.stepCount)",
                                subtitle: "Barely counts as movement",
                                color: .blue
                            )
                            
                            SummaryStatCard(
                                title: "Calories",
                                value: "\(Int(healthKitManager.latestWorkout?.calories ?? 0))",
                                subtitle: "Could be offset by a breath mint",
                                color: .orange
                            )
                            
                            SummaryStatCard(
                                title: "Workout Time",
                                value: formatDuration(healthKitManager.latestWorkout?.duration ?? 0),
                                subtitle: "Commercials last longer",
                                color: .green
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            let roast = generateDailySummaryRoast()
                            speechManager.speakRoast(roast)
                        }) {
                            HStack(spacing: 12) {
                                if speechManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                }
                                
                                Text("SHARE ROAST")
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
                        }
                        .disabled(speechManager.isSpeaking || speechManager.isLoading)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            healthKitManager.fetchWorkoutHistory()
        }
    }
    
    private func generateDailySummaryRoast() -> String {
        let steps = healthKitManager.stepCount
        let calories = Int(healthKitManager.latestWorkout?.calories ?? 0)
        let duration = healthKitManager.latestWorkout?.duration ?? 0
        
        if steps < 1000 && calories < 100 && duration < 600 {
            return "Today's performance: Absolutely pathetic. You've redefined rock bottom."
        } else if steps < 3000 {
            return "\(steps) steps, \(calories) calories burned. Even my calculator is embarrassed by these numbers."
        } else if calories < 200 {
            return "\(calories) calories? You've burned more energy being disappointed in yourself."
        } else {
            return "Not completely terrible today. Don't let it go to your head - tomorrow you'll probably disappoint me again."
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes == 0 {
            return "0m"
        }
        return "\(minutes)m"
    }
}

struct SummaryStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: iconForTitle(title))
                        .font(.title2)
                        .foregroundColor(color)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func iconForTitle(_ title: String) -> String {
        switch title.lowercased() {
        case "steps": return "figure.walk"
        case "calories": return "flame.fill"
        case "workout time": return "timer"
        default: return "chart.bar.fill"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
}
