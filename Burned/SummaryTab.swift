//
//  SummaryTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI

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
