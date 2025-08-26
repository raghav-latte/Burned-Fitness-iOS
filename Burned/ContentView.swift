//
//  ContentView.swift
//  Burned
//
//  Created by Raghav Sethi on 11/08/25.
//

import SwiftUI

enum ChallengeType {
    case steps, calories, workouts, shameScore
}

struct Challenge: Identifiable {
    let id: Int
    let title: String
    let description: String
    let target: Int
    let currentProgress: Int
    let type: ChallengeType
    let duration: Int // days
    let completed: Bool
    
    var progressPercentage: Double {
        return min(Double(currentProgress) / Double(target), 1.0)
    }
    
    var progressText: String {
        switch type {
        case .steps:
            return "\(currentProgress)/\(target) steps"
        case .calories:
            return "\(currentProgress)/\(target) cal"
        case .workouts:
            return "\(currentProgress)/\(target) workouts"
        case .shameScore:
            return "Score: \(100 - currentProgress)"
        }
    }
}

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
                                ChallengeCardView(challenge: "Survive 30 days without excuses")
                                ChallengeCardView(challenge: "Beat your laziest week record")
                                ChallengeCardView(challenge: "Burn more calories than you make excuses")
                                ChallengeCardView(challenge: "Take more steps than selfies")
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
            // Background gradient based on character
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
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 250)
                    
                    if character.imageName == "drill" ||
                        character.imageName == "narrator" ||
                        character.imageName == "female-ex" ||
                        character.imageName == "male-ex" {
                        Image(character.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 285)
                            .clipped()
                    } else {
                        VStack {
                            Image(systemName: characterIcon(for: character.name))
                                .font(.system(size: 80, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                         
                        }
                        .offset(y: -15)
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
                                .lineLimit(2...3)
                                .fixedSize(horizontal: false, vertical: true)
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
                                Text("SET")
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
        case "Your Ex (Female)":
            return Gradient(colors: [Color.purple, Color.pink])
        case "Your Ex (Male)":
            return Gradient(colors: [Color.indigo, Color.purple])
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
        case "Your Ex (Female)":
            return "heart.slash.fill"
        case "Your Ex (Male)":
            return "heart.slash.circle.fill"
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

struct EnhancedChallengeCardView: View {
    let challenge: Challenge
    @EnvironmentObject var speechManager: ElevenLabsManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    var body: some View {
        Button(action: {
            triggerChallengeRoast()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with status
                HStack {
                    Image(systemName: challenge.completed ? "checkmark.circle.fill" : "flame.fill")
                        .foregroundColor(challenge.completed ? .green : .orange)
                        .font(.title3)
                    
                    Spacer()
                    
                    if speechManager.isSpeaking {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                
                // Challenge title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Progress bar and text
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.progressText)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(challenge.completed ? .green : .orange)
                            .frame(width: CGFloat(challenge.progressPercentage) * 180, height: 6)
                    }
                    .frame(width: 180)
                }
                
                // Completion status or encouragement
                if challenge.completed {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text("COMPLETED!")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                } else {
                    HStack {
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.orange)
                            .font(.caption2)
                        Text("TAP FOR ROAST")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(width: 220)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(challenge.completed ? 
                          Color.green.opacity(0.1) : 
                          Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke((challenge.completed ? Color.green : Color.orange).opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func triggerChallengeRoast() {
        let roasts = getChallengeSpecificRoasts()
        let selectedRoast = roasts.randomElement() ?? "Stop making excuses and start making progress!"
        
        if let character = characterViewModel.selectedCharacter {
            speechManager.speakRoast(selectedRoast)
        }
    }
    
    private func getChallengeSpecificRoasts() -> [String] {
        if challenge.completed {
            return [
                "Finally! You completed \(challenge.title). Don't let it go to your head.",
                "Congrats on \(challenge.title) - now try not to immediately undo all that progress.",
                "Look who managed to finish \(challenge.title)! Shocked, honestly.",
                "\(challenge.title) complete. Your ancestors are slightly less disappointed."
            ]
        } else {
            switch challenge.type {
            case .steps:
                return [
                    "You're at \(challenge.currentProgress) steps out of \(challenge.target). Even sloths are judging you.",
                    "\(challenge.currentProgress) steps? My grandmother's Fitbit gets more action than yours.",
                    "Step challenge progress: \(challenge.currentProgress)/\(challenge.target). Pathetic doesn't begin to cover it."
                ]
            case .calories:
                return [
                    "You've burned \(challenge.currentProgress) calories. That's barely enough to power a nightlight.",
                    "\(challenge.currentProgress) calories burned? You could've achieved more energy by thinking really hard.",
                    "Calorie goal: \(challenge.target). Your progress: \(challenge.currentProgress). Mathematics has never been more depressing."
                ]
            case .workouts:
                return [
                    "\(challenge.currentProgress) workouts out of \(challenge.target)? Even Netflix asks if you're still watching because you move so little.",
                    "Workout progress: \(challenge.currentProgress)/\(challenge.target). Your gym membership is filing for abandonment.",
                    "\(challenge.currentProgress) workouts completed. Your fitness tracker thinks it's broken."
                ]
            case .shameScore:
                return [
                    "Your shame score is still embarrassing. Try moving more than your thumbs on social media.",
                    "Shame score challenge failing spectacularly. Even your shadow is more active than you.",
                    "Your shame score remains shameful. Shocking absolutely no one who knows you."
                ]
            }
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
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @StateObject private var speechManager = ElevenLabsManager.shared
    @State private var selectedPersona = "🔥"
    
    private let personas = [
        ("🔥", "Savage", "No mercy mode"),
        ("😈", "Brutal", "Maximum damage"),
        ("💀", "Ruthless", "Emotional destruction"),
        ("🤡", "Sarcastic", "Witty roasts")
    ]
    
    private var challenges: [Challenge] {
        return [
            Challenge(
                id: 1,
                title: "Step Master",
                description: "Hit 10,000 steps for 7 days straight",
                target: 10000,
                currentProgress: healthKitManager.stepCount,
                type: .steps,
                duration: 7,
                completed: false
            ),
            Challenge(
                id: 2,
                title: "Calorie Crusher",
                description: "Burn 300+ calories in a single workout",
                target: 300,
                currentProgress: Int(healthKitManager.latestWorkout?.calories ?? 0),
                type: .calories,
                duration: 1,
                completed: (healthKitManager.latestWorkout?.calories ?? 0) >= 300
            ),
            Challenge(
                id: 3,
                title: "Consistency King",
                description: "Complete 5 workouts this week",
                target: 5,
                currentProgress: healthKitManager.workoutHistory.count,
                type: .workouts,
                duration: 7,
                completed: healthKitManager.workoutHistory.count >= 5
            ),
            Challenge(
                id: 4,
                title: "Shame Score Slayer",
                description: "Get your shame score below 30",
                target: 30,
                currentProgress: Int(100 - calculateShameScore()),
                type: .shameScore,
                duration: 1,
                completed: calculateShameScore() < 30
            )
        ]
    }
    
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
                                            Circle()
                                                .stroke(getCharacterMoodStroke(), lineWidth: 3)
                                        )
                                    
                                    // Character Image or Fallback
                                    if character.imageName == "drill" ||
                                        character.imageName == "narrator" ||
                                        character.imageName == "female-ex" ||
                                        character.imageName == "male-ex" {
                                        GeometryReader { geometry in
                                            Image(character.imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
                                                .clipped()
                                                .offset(x: -geometry.size.width*0.6, y: geometry.size.height * 0.2)
                                               // .offset(y: -geometry.size.height * 0.6) // Show top 40%
                                        }
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                    } else {
                                        // Fallback to emoji for characters without images
                                        Text(getCharacterMoodEmoji())
                                            .font(.system(size: 35))
                                    }
                                }
                                .scaleEffect(speechManager.isSpeaking ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: speechManager.isSpeaking)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(character.name.uppercased())
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(getCharacterMoodText())
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        // Fitness Shame Score Meter
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
                                let roast = RoastGenerator.generateRoast(
                                    stepCount: healthKitManager.stepCount,
                                    heartRate: healthKitManager.heartRate,
                                    sleepHours: healthKitManager.sleepHours,
                                    workoutData: healthKitManager.latestWorkout,
                                    character: characterViewModel.selectedCharacter
                                )
                                speechManager.speakRoast(roast)
                            }) {
                                HStack(spacing: 8) {
                                    if speechManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "flame.fill")
                                            .font(.title3)
                                    }
                                    
                                    Text("GET ROASTED")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [.orange, .red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                )
                            }
                            .disabled(speechManager.isSpeaking || speechManager.isLoading)
                            
                            // Improve Score Button
                            Button(action: {
                                triggerQuickImprovement()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title3)
                                    Text("IMPROVE")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                    
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
                                    ForEach(Array(healthKitManager.workoutHistory.prefix(15).enumerated()), id: \.offset) { index, workout in
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
    private func getCharacterMoodColor() -> LinearGradient {
        guard let character = characterViewModel.selectedCharacter else {
            return LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
        }
        
        let score = calculateShameScore()
        switch character.name {
        case "Drill Sergeant":
            return score > 60 ? 
                LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
        case "British Narrator":
            return score > 60 ?
                LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        case "Your Ex (Female)":
            return score > 60 ?
                LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
        case "Your Ex (Male)":
            return score > 60 ?
                LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [.indigo, .blue], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
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
    
    // MARK: - Character Stroke Functions
    private func getCharacterMoodStroke() -> Color {
        let score = calculateShameScore()
        switch score {
        case 0...30: return .green
        case 31...50: return .yellow  
        case 51...75: return .orange
        default: return .red
        }
    }
    
    // MARK: - Quick Improvement Function
    private func triggerQuickImprovement() {
        let score = calculateShameScore()
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
        
        if let character = characterViewModel.selectedCharacter {
            speechManager.speakRoast(motivationalRoast)
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
                        Text(formatWorkoutName(workout.workoutType))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
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
            .padding(20)
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(workoutTypeColor(workout.workoutType).opacity(0.4), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
    
    private func formatWorkoutName(_ type: String) -> String {
        let cleanType = type.replacingOccurrences(of: "HKWorkoutActivityType", with: "")
        
        switch cleanType.lowercased() {
        // Cardio Activities
        case "running": return "Running"
        case "walking": return "Walking"
        case "cycling": return "Cycling"
        case "swimming": return "Swimming"
        case "hiking": return "Hiking"
        case "rowing": return "Rowing"
        case "stairclimbing": return "Stair Climbing"
        case "elliptical": return "Elliptical"
        case "crosstraining": return "Cross Training"
        case "steptraining": return "Step Training"
        case "fitnessgaming": return "Fitness Gaming"
        
        // Strength & Functional Training
        case "strengthtraining": return "Strength Training"
        case "functionalstrengthtraining": return "Functional Strength"
        case "coretraining": return "Core Training"
        case "flexibility": return "Flexibility"
        case "yoga": return "Yoga"
        case "pilates": return "Pilates"
        case "gymnastics": return "Gymnastics"
        case "barre": return "Barre"
        case "traditionalstrengthtraining": return "Traditional Strength"
        
        // Team Sports
        case "basketball": return "Basketball"
        case "soccer": return "Soccer"
        case "baseball": return "Baseball"
        case "americanfootball": return "Football"
        case "volleyball": return "Volleyball"
        case "hockey": return "Hockey"
        case "lacrosse": return "Lacrosse"
        case "rugby": return "Rugby"
        case "softball": return "Softball"
        case "cricket": return "Cricket"
        case "handball": return "Handball"
        case "waterpolo": return "Water Polo"
        case "australianfootball": return "Australian Football"
        
        // Racquet Sports
        case "tennis": return "Tennis"
        case "badminton": return "Badminton"
        case "tabletennis": return "Table Tennis"
        case "squash": return "Squash"
        case "racquetball": return "Racquetball"
        case "pickleball": return "Pickleball"
        
        // Combat Sports & Martial Arts
        case "martialarts": return "Martial Arts"
        case "boxing": return "Boxing"
        case "kickboxing": return "Kickboxing"
        case "taichi": return "Tai Chi"
        case "wrestling": return "Wrestling"
        case "fencing": return "Fencing"
        case "mixedmetaboliccardiotraining": return "Mixed Cardio"
        
        // Water Sports
        case "surfing": return "Surfing"
        case "paddling": return "Paddling"
        case "sailing": return "Sailing"
        case "canoeing": return "Canoeing"
        case "kayaking": return "Kayaking"
        case "fishing": return "Fishing"
        case "kitesurfing": return "Kitesurfing"
        case "standuppaddling": return "Stand Up Paddling"
        
        // Winter Sports
        case "skiing": return "Skiing"
        case "snowboarding": return "Snowboarding"
        case "skating": return "Skating"
        case "crosscountryskiing": return "Cross Country Skiing"
        case "snowshoeing": return "Snowshoeing"
        case "curling": return "Curling"
        case "sledding": return "Sledding"
        
        // High Intensity & Circuit Training
        case "highintensityintervaltraining": return "HIIT"
        case "jumpingjacks": return "Jumping Jacks"
        case "burpees": return "Burpees"
        case "jumprope": return "Jump Rope"
        
        // Dance & Movement
        case "dance": return "Dance"
        case "socialdance": return "Social Dance"
        case "cardiodance": return "Cardio Dance"
        
        // Outdoor Activities
        case "golf": return "Golf"
        case "climbing": return "Climbing"
        case "rockclimbing": return "Rock Climbing"
        case "hunting": return "Hunting"
        case "play": return "Play"
        case "track": return "Track & Field"
        case "mixedcardio": return "Mixed Cardio"
        
        // Mind & Body
        case "mindandbody": return "Mind & Body"
        case "meditation": return "Meditation"
        case "breathwork": return "Breathwork"
        
        // Low Impact & Recovery
        case "cooldown": return "Cool Down"
        case "preparation": return "Warm Up"
        case "wheelchairwalkpace": return "Wheelchair Walk"
        case "wheelchairrunpace": return "Wheelchair Run"
        
        // Individual Sports
        case "bowling": return "Bowling"
        case "archery": return "Archery"
        case "darts": return "Darts"
        case "equestrian": return "Equestrian"
        case "discsports": return "Disc Sports"
        
        // Motor Sports
        case "motorcycling": return "Motorcycling"
        
        // General Activities
        case "other": return "Other Workout"
        
        default:
            // Convert camelCase to readable format
            let result = cleanType.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            return result.capitalized
        }
    }
    
    private func workoutTypeIcon(_ type: String) -> String {
        let cleanType = type.lowercased().replacingOccurrences(of: "hkworkoutactivitytype", with: "")
        
        switch cleanType {
        // Cardio
        case "running": return "figure.run"
        case "walking": return "figure.walk"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "hiking": return "figure.hiking"
        case "rowing": return "figure.rower"
        case "stairclimbing": return "figure.stairs"
        case "elliptical": return "figure.elliptical"
        case "crosstraining": return "figure.mixed.cardio"
        case "steptraining": return "figure.step.training"
        case "fitnessgaming": return "gamecontroller.fill"
        
        // Strength & Functional
        case "strengthtraining", "functionalstrengthtraining", "traditionalstrengthtraining": return "dumbbell"
        case "coretraining": return "figure.core.training"
        case "flexibility": return "figure.flexibility"
        case "yoga": return "figure.yoga"
        case "pilates": return "figure.pilates"
        case "gymnastics": return "figure.gymnastics"
        case "barre": return "figure.barre"
        
        // Team Sports
        case "tennis": return "figure.tennis"
        case "golf": return "figure.golf"
        case "basketball": return "basketball.fill"
        case "soccer": return "soccerball"
        case "baseball": return "baseball.fill"
        case "americanfootball": return "football.fill"
        case "volleyball": return "volleyball.fill"
        case "hockey": return "hockey.puck.fill"
        case "lacrosse": return "figure.lacrosse"
        case "rugby": return "figure.rugby"
        case "softball": return "baseball.fill"
        case "cricket": return "cricket.ball.fill"
        case "handball": return "handball.fill"
        case "waterpolo": return "figure.water.polo"
        case "australianfootball": return "football.fill"
        
        // Racquet Sports
        case "badminton": return "figure.badminton"
        case "tabletennis": return "figure.table.tennis"
        case "squash": return "figure.racquetball"
        case "racquetball": return "figure.racquetball"
        case "pickleball": return "figure.pickleball"
        
        // Combat Sports & Martial Arts
        case "martialarts": return "figure.martial.arts"
        case "boxing": return "figure.boxing"
        case "kickboxing": return "figure.kickboxing"
        case "taichi": return "figure.taichi"
        case "wrestling": return "figure.wrestling"
        case "fencing": return "figure.fencing"
        case "mixedmetaboliccardiotraining": return "figure.mixed.cardio"
        
        // Water Sports
        case "surfing": return "figure.surfing"
        case "paddling": return "figure.outdoor.cycle"
        case "sailing": return "figure.sailing"
        case "canoeing": return "figure.open.water.swim"
        case "kayaking": return "figure.kayaking"
        case "fishing": return "figure.fishing"
        case "kitesurfing": return "figure.surfing"
        case "standuppaddling": return "figure.stand.and.talk"
        
        // Winter Sports
        case "skiing": return "figure.skiing.downhill"
        case "snowboarding": return "figure.snowboarding"
        case "skating": return "figure.skating"
        case "crosscountryskiing": return "figure.skiing.crosscountry"
        case "snowshoeing": return "figure.hiking"
        case "curling": return "sportscourt.fill"
        case "sledding": return "figure.skiing.downhill"
        
        // High Intensity & Circuit Training
        case "highintensityintervaltraining": return "figure.highintensity.intervaltraining"
        case "jumpingjacks": return "figure.jumprope"
        case "burpees": return "figure.burpee"
        case "jumprope": return "figure.jumprope"
        
        // Dance & Movement
        case "dance": return "figure.dance"
        case "socialdance": return "figure.socialdance"
        case "cardiodance": return "figure.dance"
        
        // Outdoor Activities
        case "golf": return "figure.golf"
        case "climbing": return "figure.climbing"
        case "rockclimbing": return "figure.climbing"
        case "hunting": return "figure.hunting"
        case "play": return "figure.play"
        case "track": return "figure.track.and.field"
        case "mixedcardio": return "figure.mixed.cardio"
        
        // Mind & Body
        case "mindandbody": return "figure.mind.and.body"
        case "meditation": return "figure.meditation"
        case "breathwork": return "lungs.fill"
        
        // Low Impact & Recovery
        case "cooldown": return "figure.cooldown"
        case "preparation": return "figure.preparation"
        case "wheelchairwalkpace": return "figure.roll"
        case "wheelchairrunpace": return "figure.roll.runningpace"
        
        // Individual Sports
        case "bowling": return "figure.bowling"
        case "archery": return "figure.archery"
        case "darts": return "target"
        case "equestrian": return "figure.equestrian.sports"
        case "discsports": return "figure.disc.sports"
        
        // Motor Sports
        case "motorcycling": return "car.fill"
        
        // Other
        case "other": return "figure.mixed.cardio"
        
        default: return "figure.mixed.cardio"
        }
    }
    
    private func workoutTypeColor(_ type: String) -> Color {
        let cleanType = type.lowercased().replacingOccurrences(of: "hkworkoutactivitytype", with: "")
        
        switch cleanType {
        // Cardio - Green family
        case "running": return .green
        case "walking": return .mint
        case "cycling": return .teal
        case "swimming": return .cyan
        case "hiking": return Color(.systemGreen)
        case "rowing": return .blue
        case "stairclimbing": return Color(.systemBlue)
        case "elliptical": return .indigo
        case "crosstraining": return .purple
        case "steptraining": return .green
        case "fitnessgaming": return .purple
        
        // Strength & Functional - Red family
        case "strengthtraining", "functionalstrengthtraining", "traditionalstrengthtraining": return .red
        case "coretraining": return .pink
        case "flexibility": return Color(.systemPink)
        case "yoga": return .purple
        case "pilates": return Color(.systemPurple)
        case "gymnastics": return .indigo
        case "barre": return .pink
        
        // Team Sports - Orange family
        case "tennis": return .orange
        case "golf": return Color(.systemGreen)
        case "basketball": return .orange
        case "soccer": return Color(.systemGreen)
        case "baseball": return .brown
        case "americanfootball": return .brown
        case "volleyball": return .yellow
        case "hockey": return .blue
        case "lacrosse": return .green
        case "rugby": return Color(.systemGreen)
        case "softball": return .brown
        case "cricket": return .green
        case "handball": return .orange
        case "waterpolo": return .cyan
        case "australianfootball": return .orange
        
        // Racquet Sports - Orange family
        case "badminton": return .green
        case "tabletennis": return .red
        case "squash": return .yellow
        case "racquetball": return .orange
        case "pickleball": return .green
        
        // Combat Sports & Martial Arts - Red family
        case "martialarts": return .red
        case "boxing": return Color(.systemRed)
        case "kickboxing": return .orange
        case "taichi": return .mint
        case "wrestling": return .red
        case "fencing": return Color(.systemGray)
        case "mixedmetaboliccardiotraining": return .red
        
        // Water Sports - Blue family
        case "surfing": return .cyan
        case "paddling": return .blue
        case "sailing": return Color(.systemBlue)
        case "canoeing": return .teal
        case "kayaking": return .cyan
        case "fishing": return .blue
        case "kitesurfing": return .cyan
        case "standuppaddling": return .teal
        
        // Winter Sports - Blue/White family
        case "skiing": return .cyan
        case "snowboarding": return .blue
        case "skating": return Color(.systemBlue)
        case "crosscountryskiing": return .mint
        case "snowshoeing": return Color(.systemBlue)
        case "curling": return .blue
        case "sledding": return .cyan
        
        // High Intensity - Red family
        case "highintensityintervaltraining": return .red
        case "jumpingjacks": return .orange
        case "burpees": return Color(.systemRed)
        case "jumprope": return .orange
        
        // Dance & Movement - Pink family
        case "dance": return .pink
        case "socialdance": return Color(.systemPink)
        case "cardiodance": return .pink
        
        // Outdoor Activities - Green family
        case "golf": return Color(.systemGreen)
        case "climbing": return .brown
        case "rockclimbing": return Color(.systemBrown)
        case "hunting": return .brown
        case "play": return .yellow
        case "track": return .orange
        case "mixedcardio": return .purple
        
        // Mind & Body - Purple family
        case "mindandbody": return .purple
        case "meditation": return .indigo
        case "breathwork": return .mint
        
        // Low Impact & Recovery - Mint family
        case "cooldown": return .mint
        case "preparation": return .yellow
        case "wheelchairwalkpace": return .mint
        case "wheelchairrunpace": return .green
        
        // Individual Sports - Various
        case "bowling": return .orange
        case "archery": return .green
        case "darts": return .red
        case "equestrian": return .brown
        case "discsports": return .orange
        
        // Motor Sports
        case "motorcycling": return .gray
        
        // Other
        case "other": return .gray
        
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
                        Text(formatWorkoutName(workout.workoutType))
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
        let cleanType = type.lowercased().replacingOccurrences(of: "hkworkoutactivitytype", with: "")
        
        switch cleanType {
        // Cardio
        case "running": return "figure.run"
        case "walking": return "figure.walk"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "hiking": return "figure.hiking"
        case "rowing": return "figure.rower"
        case "stairclimbing": return "figure.stairs"
        case "elliptical": return "figure.elliptical"
        case "crosstraining": return "figure.mixed.cardio"
        case "steptraining": return "figure.step.training"
        case "fitnessgaming": return "gamecontroller.fill"
        
        // Strength & Functional
        case "strengthtraining", "functionalstrengthtraining", "traditionalstrengthtraining": return "dumbbell"
        case "coretraining": return "figure.core.training"
        case "flexibility": return "figure.flexibility"
        case "yoga": return "figure.yoga"
        case "pilates": return "figure.pilates"
        case "gymnastics": return "figure.gymnastics"
        case "barre": return "figure.barre"
        
        // Team Sports
        case "tennis": return "figure.tennis"
        case "golf": return "figure.golf"
        case "basketball": return "basketball.fill"
        case "soccer": return "soccerball"
        case "baseball": return "baseball.fill"
        case "americanfootball": return "football.fill"
        case "volleyball": return "volleyball.fill"
        case "hockey": return "hockey.puck.fill"
        case "lacrosse": return "figure.lacrosse"
        case "rugby": return "figure.rugby"
        case "softball": return "baseball.fill"
        case "cricket": return "cricket.ball.fill"
        case "handball": return "handball.fill"
        case "waterpolo": return "figure.water.polo"
        case "australianfootball": return "football.fill"
        
        // Racquet Sports
        case "badminton": return "figure.badminton"
        case "tabletennis": return "figure.table.tennis"
        case "squash": return "figure.racquetball"
        case "racquetball": return "figure.racquetball"
        case "pickleball": return "figure.pickleball"
        
        // Combat Sports & Martial Arts
        case "martialarts": return "figure.martial.arts"
        case "boxing": return "figure.boxing"
        case "kickboxing": return "figure.kickboxing"
        case "taichi": return "figure.taichi"
        case "wrestling": return "figure.wrestling"
        case "fencing": return "figure.fencing"
        case "mixedmetaboliccardiotraining": return "figure.mixed.cardio"
        
        // Water Sports
        case "surfing": return "figure.surfing"
        case "paddling": return "figure.outdoor.cycle"
        case "sailing": return "figure.sailing"
        case "canoeing": return "figure.open.water.swim"
        case "kayaking": return "figure.kayaking"
        case "fishing": return "figure.fishing"
        case "kitesurfing": return "figure.surfing"
        case "standuppaddling": return "figure.stand.and.talk"
        
        // Winter Sports
        case "skiing": return "figure.skiing.downhill"
        case "snowboarding": return "figure.snowboarding"
        case "skating": return "figure.skating"
        case "crosscountryskiing": return "figure.skiing.crosscountry"
        case "snowshoeing": return "figure.hiking"
        case "curling": return "sportscourt.fill"
        case "sledding": return "figure.skiing.downhill"
        
        // High Intensity & Circuit Training
        case "highintensityintervaltraining": return "figure.highintensity.intervaltraining"
        case "jumpingjacks": return "figure.jumprope"
        case "burpees": return "figure.burpee"
        case "jumprope": return "figure.jumprope"
        
        // Dance & Movement
        case "dance": return "figure.dance"
        case "socialdance": return "figure.socialdance"
        case "cardiodance": return "figure.dance"
        
        // Outdoor Activities
        case "golf": return "figure.golf"
        case "climbing": return "figure.climbing"
        case "rockclimbing": return "figure.climbing"
        case "hunting": return "figure.hunting"
        case "play": return "figure.play"
        case "track": return "figure.track.and.field"
        case "mixedcardio": return "figure.mixed.cardio"
        
        // Mind & Body
        case "mindandbody": return "figure.mind.and.body"
        case "meditation": return "figure.meditation"
        case "breathwork": return "lungs.fill"
        
        // Low Impact & Recovery
        case "cooldown": return "figure.cooldown"
        case "preparation": return "figure.preparation"
        case "wheelchairwalkpace": return "figure.roll"
        case "wheelchairrunpace": return "figure.roll.runningpace"
        
        // Individual Sports
        case "bowling": return "figure.bowling"
        case "archery": return "figure.archery"
        case "darts": return "target"
        case "equestrian": return "figure.equestrian.sports"
        case "discsports": return "figure.disc.sports"
        
        // Motor Sports
        case "motorcycling": return "car.fill"
        
        // Other
        case "other": return "figure.mixed.cardio"
        
        default: return "figure.mixed.cardio"
        }
    }
    
    private func workoutTypeColor(_ type: String) -> Color {
        let cleanType = type.lowercased().replacingOccurrences(of: "hkworkoutactivitytype", with: "")
        
        switch cleanType {
        // Cardio - Green family
        case "running": return .green
        case "walking": return .mint
        case "cycling": return .teal
        case "swimming": return .cyan
        case "hiking": return Color(.systemGreen)
        case "rowing": return .blue
        case "stairclimbing": return Color(.systemBlue)
        case "elliptical": return .indigo
        case "crosstraining": return .purple
        case "steptraining": return .green
        case "fitnessgaming": return .purple
        
        // Strength & Functional - Red family
        case "strengthtraining", "functionalstrengthtraining", "traditionalstrengthtraining": return .red
        case "coretraining": return .pink
        case "flexibility": return Color(.systemPink)
        case "yoga": return .purple
        case "pilates": return Color(.systemPurple)
        case "gymnastics": return .indigo
        case "barre": return .pink
        
        // Team Sports - Orange family
        case "tennis": return .orange
        case "golf": return Color(.systemGreen)
        case "basketball": return .orange
        case "soccer": return Color(.systemGreen)
        case "baseball": return .brown
        case "americanfootball": return .brown
        case "volleyball": return .yellow
        case "hockey": return .blue
        case "lacrosse": return .green
        case "rugby": return Color(.systemGreen)
        case "softball": return .brown
        case "cricket": return .green
        case "handball": return .orange
        case "waterpolo": return .cyan
        case "australianfootball": return .orange
        
        // Racquet Sports - Orange family
        case "badminton": return .green
        case "tabletennis": return .red
        case "squash": return .yellow
        case "racquetball": return .orange
        case "pickleball": return .green
        
        // Combat Sports & Martial Arts - Red family
        case "martialarts": return .red
        case "boxing": return Color(.systemRed)
        case "kickboxing": return .orange
        case "taichi": return .mint
        case "wrestling": return .red
        case "fencing": return Color(.systemGray)
        case "mixedmetaboliccardiotraining": return .red
        
        // Water Sports - Blue family
        case "surfing": return .cyan
        case "paddling": return .blue
        case "sailing": return Color(.systemBlue)
        case "canoeing": return .teal
        case "kayaking": return .cyan
        case "fishing": return .blue
        case "kitesurfing": return .cyan
        case "standuppaddling": return .teal
        
        // Winter Sports - Blue/White family
        case "skiing": return .cyan
        case "snowboarding": return .blue
        case "skating": return Color(.systemBlue)
        case "crosscountryskiing": return .mint
        case "snowshoeing": return Color(.systemBlue)
        case "curling": return .blue
        case "sledding": return .cyan
        
        // High Intensity - Red family
        case "highintensityintervaltraining": return .red
        case "jumpingjacks": return .orange
        case "burpees": return Color(.systemRed)
        case "jumprope": return .orange
        
        // Dance & Movement - Pink family
        case "dance": return .pink
        case "socialdance": return Color(.systemPink)
        case "cardiodance": return .pink
        
        // Outdoor Activities - Green family
        case "golf": return Color(.systemGreen)
        case "climbing": return .brown
        case "rockclimbing": return Color(.systemBrown)
        case "hunting": return .brown
        case "play": return .yellow
        case "track": return .orange
        case "mixedcardio": return .purple
        
        // Mind & Body - Purple family
        case "mindandbody": return .purple
        case "meditation": return .indigo
        case "breathwork": return .mint
        
        // Low Impact & Recovery - Mint family
        case "cooldown": return .mint
        case "preparation": return .yellow
        case "wheelchairwalkpace": return .mint
        case "wheelchairrunpace": return .green
        
        // Individual Sports - Various
        case "bowling": return .orange
        case "archery": return .green
        case "darts": return .red
        case "equestrian": return .brown
        case "discsports": return .orange
        
        // Motor Sports
        case "motorcycling": return .gray
        
        // Other
        case "other": return .gray
        
        default: return .gray
        }
    }
    
    private func formatWorkoutName(_ type: String) -> String {
        let cleanType = type.replacingOccurrences(of: "HKWorkoutActivityType", with: "")
        
        switch cleanType.lowercased() {
        case "running": return "Running"
        case "walking": return "Walking"
        case "cycling": return "Cycling"
        case "swimming": return "Swimming"
        case "hiking": return "Hiking"
        case "rowing": return "Rowing"
        case "stairclimbing": return "Stair Climbing"
        case "elliptical": return "Elliptical"
        case "crosstraining": return "Cross Training"
        case "strengthtraining": return "Strength Training"
        case "functionalstrengthtraining": return "Functional Strength"
        case "coretraining": return "Core Training"
        case "flexibility": return "Flexibility"
        case "yoga": return "Yoga"
        case "pilates": return "Pilates"
        case "gymnastics": return "Gymnastics"
        case "tennis": return "Tennis"
        case "golf": return "Golf"
        case "basketball": return "Basketball"
        case "soccer": return "Soccer"
        case "baseball": return "Baseball"
        case "americanfootball": return "Football"
        case "volleyball": return "Volleyball"
        case "badminton": return "Badminton"
        case "tabletennis": return "Table Tennis"
        case "dance": return "Dance"
        case "martialarts": return "Martial Arts"
        case "boxing": return "Boxing"
        case "kickboxing": return "Kickboxing"
        case "taichi": return "Tai Chi"
        case "surfing": return "Surfing"
        case "paddling": return "Paddling"
        case "sailing": return "Sailing"
        case "skiing": return "Skiing"
        case "snowboarding": return "Snowboarding"
        case "skating": return "Skating"
        case "highintensityintervaltraining": return "HIIT"
        case "jumpingjacks": return "Jumping Jacks"
        case "burpees": return "Burpees"
        case "mindandbody": return "Mind & Body"
        case "meditation": return "Meditation"
        case "breathwork": return "Breathwork"
        case "other": return "Other Workout"
        case "cooldown": return "Cool Down"
        case "preparation": return "Warm Up"
        default:
            // Convert camelCase to readable format
            let result = cleanType.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            return result.capitalized
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
