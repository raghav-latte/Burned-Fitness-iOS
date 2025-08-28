//
//  SettingsTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI

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
