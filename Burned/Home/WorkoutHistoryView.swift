//
//  WorkoutHistoryView.swift
//  Burned
//
//  Created by Raghav Sethi on 08/09/25.
//
import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @ObservedObject private var speechManager = ElevenLabsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if healthKitManager.workoutHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No workouts found")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Text("Start working out to build your history!")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(healthKitManager.workoutHistory) { workout in
                                WorkoutHistoryRow(
                                    workout: workout,
                                    speechManager: speechManager
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct WorkoutHistoryRow: View {
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
                        
                        Text(formatWorkoutDate(workout.date))
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
                        if let indicator = getPerformanceIndicator() {
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
    
    private func workoutTypeIcon(_ type: String) -> String {
        let displayType = displayWorkoutType(type)
        switch displayType.lowercased() {
        case "sprint screening": return "timer"
        case "running": return "figure.run"
        case "walking": return "figure.walk"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "yoga": return "figure.mind.and.body"
        case "strength training", "functional training": return "dumbbell"
        case "core training": return "figure.core.training"
        case "stair climbing machine": return "figure.stairs"
        default: return "figure.mixed.cardio"
        }
    }
    
    private func workoutTypeColor(_ type: String) -> Color {
        let displayType = displayWorkoutType(type)
        switch displayType.lowercased() {
        case "sprint screening": return .purple
        case "running": return .green
        case "walking": return .blue
        case "cycling": return .orange
        case "swimming": return .cyan
        case "yoga": return .purple
        case "strength training", "functional training": return .red
        case "core training": return .pink
        case "stair climbing machine": return .indigo
        default: return .gray
        }
    }
    
    private func formatWorkoutDate(_ date: Date) -> String {
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
}
