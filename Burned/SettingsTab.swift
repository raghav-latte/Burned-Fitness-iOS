//
//  SettingsTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI
import RevenueCatUI

struct SettingsTab: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var roastIntensity: Double = 3.0
    @State private var notificationStyle: Int = 0
    @State private var reminderFrequency: Double = 4.0
    @State private var isPaywallPresented = false
    
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
                        
                    }
                    .padding(.horizontal, 20)
                  
                    
                    // Legal Section
                    VStack(spacing: 12) {
                        Text("Legal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 8) {
                            LegalLinkButton(title: "Terms of Service", url: "https://raghav-latte.github.io/Burned-Fitness-iOS/terms-of-service.html")
                            LegalLinkButton(title: "Privacy Policy", url: "https://raghav-latte.github.io/Burned-Fitness-iOS/privacy-policy.html")
                            LegalLinkButton(title: "End User License Agreement", url: "https://raghav-latte.github.io/Burned-Fitness-iOS/eula.html")
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
        .sheet(isPresented: $isPaywallPresented) {
            PaywallView(displayCloseButton: true)
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

struct LegalLinkButton: View {
    let title: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }
}
