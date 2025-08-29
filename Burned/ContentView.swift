//
//  ContentView.swift
//  Burned
//
//  Created by Raghav Sethi on 11/08/25.
//

import SwiftUI
import AIProxy

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
        .ignoresSafeArea(.all)

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
  
