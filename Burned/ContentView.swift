//
//  ContentView.swift
//  Burned
//
//  Created by Raghav Sethi on 11/08/25.
//

import SwiftUI
import AIProxy

@available(iOS 26.0, *)
struct AlarmVerificationData {
    let alarmType: AlarmType
    let characterName: String
}

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
    @State private var showSplash = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var showAlarmVerification = false
    @State private var alarmVerificationData: Any?
    
    // Debug properties
    @State private var debugAlarmType: String = ""
    @State private var debugCharacterName: String = ""
    @State private var debugAlarmID: String = ""
    
    var body: some View {
        ZStack {
            // Background that extends into status bar
            Color.black.ignoresSafeArea(.all)
            
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
        .ignoresSafeArea(.container, edges: .top)
        .accentColor(.orange)
        .onAppear {
            configureTabBarAppearance()
        }
        
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
                .transition(.move(edge: .bottom))
                .zIndex(2)
        }
        // Character selection overlay (only show if onboarding is complete)
        else if characterViewModel.selectedCharacter == nil || characterViewModel.showCharacterSelection {
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
        .onOpenURL { url in
            handleAlarmURL(url)
        }
        .fullScreenCover(isPresented: $showAlarmVerification) {
            if #available(iOS 26.0, *) {
                // Use debug properties to create the verification view directly
                let alarmType = AlarmType.allCases.first(where: { $0.rawValue == debugAlarmType }) ?? .wakeUp
                let characterName = debugCharacterName.isEmpty ? "British Narrator" : debugCharacterName
                
                AlarmWakeUpVerificationView(
                    alarmType: alarmType,
                    characterName: characterName,
                    alarmID: debugAlarmID.isEmpty ? nil : debugAlarmID
                )
            } else {
                // iOS < 26.0 fallback
                ZStack {
                    Color.red.ignoresSafeArea()
                    VStack {
                        Text("iOS 26.0+ Required")
                            .font(.title)
                            .foregroundColor(.white)
                        Button("Close") {
                            showAlarmVerification = false
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.red)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .ignoresSafeArea(.all)

    }
    
    private func handleAlarmURL(_ url: URL) {
        print("🔗 Received URL: \(url.absoluteString)")
        
        // Handle alarm app opening with alarm data
        guard #available(iOS 26.0, *) else {
            print("⚠️ AlarmKit not available on this iOS version")
            return
        }
        
        // Handle basic app opening without alarm data
        guard url.scheme == "burned" else {
            print("⚠️ Invalid URL scheme: \(url.scheme ?? "nil")")
            return
        }
        
        // If it's just burned:// without alarm path, show test verification for debugging
        guard url.host == "alarm" else {
            print("✅ App opened normally via URL scheme")
            // DEBUG: Show test verification for any app opening
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if #available(iOS 26.0, *) {
                    print("🧪 DEBUG: Creating test data...")
                    let testData = AlarmVerificationData(alarmType: .wakeUp, characterName: "British Narrator")
                    print("🧪 DEBUG: Test data created: \(testData.alarmType.rawValue) - \(testData.characterName)")
                    
                    self.alarmVerificationData = testData
                    print("🧪 DEBUG: Test data set: \(String(describing: self.alarmVerificationData))")
                    
                    self.showAlarmVerification = true
                    print("🧪 DEBUG: Modal triggered: \(self.showAlarmVerification)")
                } else {
                    print("❌ DEBUG: iOS version < 26.0, AlarmVerificationData not available")
                    // Show a simple test modal for older iOS
                    self.showAlarmVerification = true
                }
            }
            return
        }
        
        // Parse URL to extract alarm information
        // Example: burned://alarm?type=wakeUp&character=Drill%20Sergeant
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            print("⚠️ Could not parse URL components")
            return
        }
        
        var alarmTypeString: String?
        var characterName: String?
        var alarmID: String?
        
        for item in queryItems {
            switch item.name {
            case "type":
                alarmTypeString = item.value
            case "character":
                characterName = item.value
            case "alarmID":
                alarmID = item.value
            default:
                break
            }
        }
        
        print("📱 Parsed - Type: \(alarmTypeString ?? "nil"), Character: \(characterName ?? "nil")")
        
        guard let typeString = alarmTypeString,
              let character = characterName,
              let type = AlarmType.allCases.first(where: { $0.rawValue.lowercased() == typeString.lowercased() }) else {
            print("⚠️ Could not parse alarm data from URL")
            return
        }
        
        print("🎯 Showing wake-up verification for \(type.rawValue) with \(character)")
        
        // Show alarm verification with a slight delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if #available(iOS 26.0, *) {
                print("🔄 Creating AlarmVerificationData...")
                let verificationData = AlarmVerificationData(alarmType: type, characterName: character)
                print("🔄 Created verificationData: \(verificationData.alarmType.rawValue) - \(verificationData.characterName)")
                
                print("🔄 Setting alarmVerificationData...")
                self.alarmVerificationData = verificationData
                print("🔄 alarmVerificationData is now: \(String(describing: self.alarmVerificationData))")
                
                // Also set debug properties
                self.debugAlarmType = verificationData.alarmType.rawValue
                self.debugCharacterName = verificationData.characterName
                self.debugAlarmID = alarmID ?? ""
                print("🔄 Debug properties set: \(self.debugAlarmType) - \(self.debugCharacterName) - \(self.debugAlarmID)")
                
                print("🔄 Setting showAlarmVerification to true...")
                self.showAlarmVerification = true
                print("🔄 showAlarmVerification is now: \(self.showAlarmVerification)")
                
                // Check immediately after setting
                print("🔍 Immediate check - alarmVerificationData: \(String(describing: self.alarmVerificationData))")
                print("🔍 Immediate check - showAlarmVerification: \(self.showAlarmVerification)")
                
                // Additional debugging
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("🔍 After 1 second - showAlarmVerification = \(self.showAlarmVerification)")
                    print("🔍 After 1 second - alarmVerificationData = \(String(describing: self.alarmVerificationData))")
 
                    if let data = self.alarmVerificationData as? AlarmVerificationData {
                        print("🔍 Cast successful: \(data.alarmType.rawValue) - \(data.characterName)")
                    } else {
                        print("❌ Cast to AlarmVerificationData failed")
                    }
                }
            } else {
                print("❌ iOS version < 26.0, cannot create AlarmVerificationData")
                // Show simple debug modal
                self.showAlarmVerification = true
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
  
