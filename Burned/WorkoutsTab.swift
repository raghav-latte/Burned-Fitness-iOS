//
//  WorkoutsTab.swift
//  Burned
//
//  Created by Raghav Sethi on 04/10/25.
//

import SwiftUI
import HealthKit

@available(iOS 26.0, *)
struct WorkoutsTab: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var showWorkoutSelection = false
    
    var body: some View {
        if #available(iOS 26.0, *) {
            WorkoutsTabContent()
        } else {
            Text("Workouts require iOS 26.0 or later")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

@available(iOS 26.0, *)
struct WorkoutsTabContent: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if workoutManager.state == .notStarted || workoutManager.state == .ended {
                    WorkoutSelectionView()
                        .environmentObject(workoutManager)
                } else {
                    ActiveWorkoutView()
                        .environmentObject(workoutManager)
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if workoutManager.state != .notStarted && workoutManager.state != .ended {
                        Button("End") {
                            workoutManager.endWorkout()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}

@available(iOS 26.0, *)
struct WorkoutSelectionView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Choose Your Workout")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(WorkoutTypes.workoutConfigurations, id: \.hashValue) { configuration in
                        WorkoutCard(configuration: configuration)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

@available(iOS 26.0, *)
struct WorkoutCard: View {
    let configuration: HKWorkoutConfiguration
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        Button(action: {
            workoutManager.selectedWorkout = configuration
        }) {
            VStack(spacing: 16) {
                Image(systemName: configuration.symbol)
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                Text(configuration.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if configuration.supportsDistance {
                    HStack {
                        Image(systemName: "lines.measurement.horizontal")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(workoutManager.selectedWorkout != nil && workoutManager.selectedWorkout != configuration)
        .opacity(workoutManager.selectedWorkout != nil && workoutManager.selectedWorkout != configuration ? 0.6 : 1.0)
    }
}

@available(iOS 26.0, *)
struct ActiveWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Workout Type and Timer
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: workoutManager.workoutConfiguration?.symbol ?? "figure.run")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(workoutManager.workoutConfiguration?.name ?? "Workout")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(workoutStateText)
                            .font(.caption)
                            .foregroundColor(workoutStateColor)
                    }
                }
                
                Text(workoutManager.metrics.getFormattedTime())
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Metrics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Heart Rate",
                    value: workoutManager.metrics.getHeartRate(),
                    unit: "bpm",
                    icon: "heart.fill",
                    color: .red,
                    showData: workoutManager.metrics.heartRate != nil
                )
                
                if workoutManager.metrics.supportsDistance {
                    MetricCard(
                        title: "Distance",
                        value: workoutManager.metrics.getDistance(),
                        unit: "",
                        icon: "lines.measurement.horizontal",
                        color: .green,
                        showData: workoutManager.metrics.distance != nil
                    )
                }
                
                MetricCard(
                    title: "Calories",
                    value: workoutManager.metrics.getActiveEnergy(),
                    unit: "cal",
                    icon: "flame.fill",
                    color: .purple,
                    showData: workoutManager.metrics.activeEnergy != nil
                )
            }
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 20) {
                if workoutManager.state == .prepared {
                    Button(action: {
                        workoutManager.startWorkout()
                    }) {
                        Text("START WORKOUT")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.orange)
                            .cornerRadius(16)
                    }
                } else {
                    Button(action: {
                        workoutManager.togglePause()
                    }) {
                        Text(workoutManager.state == .running ? "PAUSE" : "RESUME")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.orange)
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        workoutManager.endWorkout()
                    }) {
                        Text("END")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.red)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var workoutStateText: String {
        switch workoutManager.state {
        case .prepared:
            return "Ready to start"
        case .running:
            return "In progress"
        case .paused:
            return "Paused"
        case .stopped:
            return "Ending..."
        case .ended:
            return "Completed"
        default:
            return "Getting ready..."
        }
    }
    
    private var workoutStateColor: Color {
        switch workoutManager.state {
        case .prepared:
            return .orange
        case .running:
            return .green
        case .paused:
            return .yellow
        case .stopped, .ended:
            return .red
        default:
            return .gray
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let showData: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                if showData {
                    HStack(alignment: .bottom, spacing: 2) {
                        Text(value)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if !unit.isEmpty {
                            Text(unit)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Text("--")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
 
