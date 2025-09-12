//
//  OnboardingPages.swift
//  Burned
//
//  Created by Raghav Sethi on 30/08/25.
//

import SwiftUI
import HealthKit
import UserNotifications

// MARK: - Page 1: Why Burned?
struct WhyBurnedPage: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("🔥")
                    .font(.system(size: 80))
                
                Text("Welcome to BURNED")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Finally, a fitness app that tells you the truth")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 20) {
                FeatureBullet(icon: "💀", title: "Brutal Honesty", description: "No sugar-coating your fitness failures")
                FeatureBullet(icon: "🎭", title: "AI Characters", description: "Choose your personal fitness tormentor")
                FeatureBullet(icon: "📊", title: "Shame Score", description: "Track your fitness disappointments")
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            OnboardingButton(title: "Let's Get Started", action: onNext)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 2: Name Input
struct NameInputPage: View {
    @Binding var userName: String
    let onNext: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("What's Your Name?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("We'll use this to personalize your roasts")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 20) {
                TextField("Enter your name", text: $userName)
                    .focused($isTextFieldFocused)
                    .font(.title2)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isTextFieldFocused ? Color.orange : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .padding(.horizontal, 30)
                
                if !userName.isEmpty {
                    Text("Nice to meet you, \(userName)!")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .animation(.easeInOut(duration: 0.3), value: userName)
                }
            }
            
            Spacer()
            
            OnboardingButton(
                title: "Continue",
                action: {
                    isTextFieldFocused = false
                    onNext()
                },
                isEnabled: !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Page 3: Choose Intensity
struct IntensitySelectionPage: View {
    @Binding var selectedIntensity: Double
    let onNext: () -> Void
    
    private let intensityLabels = ["Gentle", "Mild", "Medium", "Savage", "Brutal"]
    private let intensityEmojis = ["🙂", "😐", "😬", "🔥", "💀"]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Choose Your Pain Level")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("How brutal should your roasts be?")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 30) {
                Text(intensityEmojis[Int(selectedIntensity)])
                    .font(.system(size: 100))
                
                Text(intensityLabels[Int(selectedIntensity)])
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                VStack(spacing: 20) {
                    Slider(value: $selectedIntensity, in: 0...4, step: 1)
                        .accentColor(.orange)
                        .padding(.horizontal, 40)
                    
                    HStack {
                        Text("Gentle")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Brutal")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()
            
            OnboardingButton(title: "Continue", action: onNext)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 3: Character Selection
struct CharacterSelectionPage: View {
    @Binding var selectedCharacter: Character?
    let onNext: () -> Void
    
    private let characters = Character.allCharacters
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Choose Your Tormentor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Pick the AI personality that will motivate you")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(characters, id: \.id) { character in
                        OnboardingCharacterCard(
                            character: character,
                            isSelected: selectedCharacter?.id == character.id
                        ) {
                            selectedCharacter = character
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            OnboardingButton(
                title: "Continue",
                action: onNext,
                isEnabled: selectedCharacter != nil
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 4: Triggering Words
struct TriggeringWordsPage: View {
    @Binding var triggeringWords: [String]
    let onNext: () -> Void
    @State private var customWord = ""
    
    private let predefinedWords = [
        "Lazy", "Pathetic", "Disappointing", "Weak", 
        "Useless", "Shameful", "Embarrassing", "Failure"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("What Gets You Moving?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Select words that trigger your motivation")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(predefinedWords, id: \.self) { word in
                            TriggerWordButton(
                                word: word,
                                isSelected: triggeringWords.contains(word)
                            ) {
                                if triggeringWords.contains(word) {
                                    triggeringWords.removeAll { $0 == word }
                                } else {
                                    triggeringWords.append(word)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        Text("Add Custom Word")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            TextField("Enter word...", text: $customWord)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !customWord.isEmpty && !triggeringWords.contains(customWord) {
                                    triggeringWords.append(customWord)
                                    customWord = ""
                                }
                            }
                            .foregroundColor(.orange)
                            .disabled(customWord.isEmpty)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            OnboardingButton(title: "Continue", action: onNext)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 5: Motivation Questionnaire
struct MotivationQuestionnairePage: View {
    @Binding var motivationReasons: [String]
    let onNext: () -> Void
    
    private let reasons = [
        "Lost motivation for workouts",
        "Need accountability partner",
        "Want to build consistency",
        "Tired of generic fitness apps",
        "Respond well to tough love",
        "Need external pressure",
        "Want entertaining fitness tracking",
        "Struggle with self-discipline"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Why Are You Here?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Select all that apply (be honest)")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(reasons, id: \.self) { reason in
                        MotivationReasonButton(
                            reason: reason,
                            isSelected: motivationReasons.contains(reason)
                        ) {
                            if motivationReasons.contains(reason) {
                                motivationReasons.removeAll { $0 == reason }
                            } else {
                                motivationReasons.append(reason)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            OnboardingButton(
                title: "Continue",
                action: onNext,
                isEnabled: !motivationReasons.isEmpty
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 6: Time Preferences
struct TimePreferencesPage: View {
    @Binding var wakeUpTime: Date
    @Binding var workoutTime: Date
    @Binding var bedTime: Date
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Set Your Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("When do you usually wake up, work out, and sleep?")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            VStack(spacing: 24) {
                TimeSelectionCard(
                    title: "Wake Up Time",
                    icon: "sun.max.fill",
                    time: $wakeUpTime,
                    color: .yellow
                )
                
                TimeSelectionCard(
                    title: "Workout Time",
                    icon: "dumbbell.fill",
                    time: $workoutTime,
                    color: .orange
                )
                
                TimeSelectionCard(
                    title: "Bed Time",
                    icon: "moon.fill",
                    time: $bedTime,
                    color: .purple
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            OnboardingButton(title: "Continue", action: onNext)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 7: Wakeup and Sleep Times
struct WakeupSleepTimesPage: View {
    @Binding var wakeUpTime: Date
    @Binding var sleepTime: Date
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Set Your Sleep Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("When do you usually wake up and go to sleep?")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            VStack(spacing: 24) {
                TimeSelectionCard(
                    title: "Wake Up Time",
                    icon: "sun.max.fill",
                    time: $wakeUpTime,
                    color: .yellow
                )
                
                TimeSelectionCard(
                    title: "Sleep Time",
                    icon: "moon.fill",
                    time: $sleepTime,
                    color: .purple
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            OnboardingButton(title: "Continue", action: onNext)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Page 8: Permissions
struct PermissionsPage: View {
    let onComplete: () -> Void
    @State private var healthPermissionGranted = false
    @State private var notificationPermissionGranted = false
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Final Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("We need these permissions to roast you properly")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            VStack(spacing: 20) {
                PermissionCard(
                    icon: "heart.fill",
                    title: "Health Data Access",
                    description: "Track your workouts, steps, and fitness metrics",
                    isGranted: healthPermissionGranted,
                    action: requestHealthPermission
                )
                
                PermissionCard(
                    icon: "bell.fill",
                    title: "Push Notifications",
                    description: "Get roasted when you're slacking off",
                    isGranted: notificationPermissionGranted,
                    action: requestNotificationPermission
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                OnboardingButton(
                    title: "Start Getting Roasted",
                    action: onComplete,
                    isEnabled: healthPermissionGranted && notificationPermissionGranted
                )
                
                Button("Skip for now") {
                    onComplete()
                }
                .font(.body)
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .onAppear {
            checkCurrentPermissions()
        }
    }
    
    private func checkCurrentPermissions() {
        // Check current HealthKit status
        healthPermissionGranted = healthKitManager.isAuthorized
        
        // Check current notification status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func requestHealthPermission() {
        healthKitManager.requestAuthorization()
        
        // Check permission status after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            healthPermissionGranted = healthKitManager.isAuthorized
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationPermissionGranted = granted
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FeatureBullet: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct OnboardingCharacterCard: View {
    let character: Character
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Text(character.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(character.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 2)
                    )
            )
        }
    }
}

struct TriggerWordButton: View {
    let word: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(word)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.orange : Color.gray.opacity(0.3))
                )
        }
    }
}

struct MotivationReasonButton: View {
    let reason: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? .orange : .gray)
                
                Text(reason)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isGranted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Button("Grant") {
                        action()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isGranted ? Color.green.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct OnboardingButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    
    init(title: String, action: @escaping () -> Void, isEnabled: Bool = true) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isEnabled ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? 
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : 
                            LinearGradient(
                                gradient: Gradient(colors: [.gray, .gray]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(!isEnabled)
    }
}

struct TimeSelectionCard: View {
    let title: String
    let icon: String
    @Binding var time: Date
    let color: Color
    @State private var showTimePicker = false
    
    var body: some View {
        Button(action: {
            showTimePicker = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(formatTime(time))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(time: $time, title: title, color: color)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TimePickerSheet: View {
    @Binding var time: Date
    let title: String
    let color: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Select \(title)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(color)
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}