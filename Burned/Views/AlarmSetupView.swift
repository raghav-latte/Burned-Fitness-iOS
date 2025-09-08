import SwiftUI
import AlarmKit

@available(iOS 26.0, *)
struct AlarmSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @State private var alarmManager = BurnedAlarmManager.shared
    
    @State private var selectedAlarmType: AlarmType = .wakeUp
    @State private var selectedTime = Date()
    @State private var selectedDays = Set<Locale.Weekday>()
    @State private var showingAlarmList = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    headerView
                    alarmTypeSelector
                    characterDisplay
                    timeSelector
                    weekdaySelector
                    actionButtons
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAlarmList) {
            AlarmListView()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("Setup Alarm")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Manage") {
                    showingAlarmList = true
                }
                .foregroundColor(.orange)
            }
            
            Text("Let your character wake you up")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    private var alarmTypeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alarm Type")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(AlarmType.allCases, id: \.self) { type in
                    AlarmTypeButton(
                        type: type,
                        isSelected: selectedAlarmType == type
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedAlarmType = type
                        }
                    }
                }
            }
        }
    }
    
    private var characterDisplay: some View {
        VStack(spacing: 20) {
            if let currentCharacter = characterViewModel.selectedCharacter {
                ZStack {
                    // Background gradient matching alarm type
                    RadialGradient(
                        gradient: selectedAlarmType.gradient,
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                    .opacity(0.3)
                    
                    VStack(spacing: 16) {
                        // Character image
                        Image(currentCharacter.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: selectedAlarmType.gradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        VStack(spacing: 8) {
                            Text(currentCharacter.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(alarmMessage)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .frame(height: 320)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        gradient: selectedAlarmType.gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            }
        }
    }
    
    private var timeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Time")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6).opacity(0.1))
                )
        }
    }
    
    private var weekdaySelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                Text("Repeat Days")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 8) {
                ForEach(Locale.current.orderedWeekdays, id: \.self) { weekday in
                    WeekdayButton(
                        weekday: weekday,
                        isSelected: selectedDays.contains(weekday)
                    ) {
                        if selectedDays.contains(weekday) {
                            selectedDays.remove(weekday)
                        } else {
                            selectedDays.insert(weekday)
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: scheduleAlarm) {
                HStack {
                    Image(systemName: selectedAlarmType.icon)
                    Text("Schedule \(selectedAlarmType.rawValue) Alarm")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: selectedAlarmType.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .disabled(characterViewModel.selectedCharacter == nil)
        }
        .padding(.bottom, 40)
    }
    
    private var alarmMessage: String {
        guard let character = characterViewModel.selectedCharacter else { return "" }
        
        let messages: [AlarmType: [String: String]] = [
            .wakeUp: [
                "Drill Sergeant": "WAKE UP, SOLDIER!",
                "British Narrator": "Rise and shine",
                "Your Ex (Female)": "Remember when you used to wake up early?",
                "Your Ex (Male)": "Bro, even your alarm is disappointed"
            ],
            .workout: [
                "Drill Sergeant": "DROP AND GIVE ME TWENTY! NO EXCUSES!",
                "British Narrator": "Time for your daily dose of regret and burpees.",
                "Your Ex (Female)": "Working out without me? How original.",
                "Your Ex (Male)": "Still need me to motivate you, huh? Some things never change."
            ],
            .sleep: [
                "Drill Sergeant": "LIGHTS OUT, SOLDIER! GET YOUR BEAUTY SLEEP!",
                "British Narrator": "Even your pillow is tired of waiting for you.",
                "Your Ex (Female)": "Sweet dreams... if you can manage them.",
                "Your Ex (Male)": "Finally going to bed at a decent time? Miracle."
            ]
        ]
        
        return messages[selectedAlarmType]?[character.name] ?? selectedAlarmType.description
    }
    
    private func scheduleAlarm() {
        guard let character = characterViewModel.selectedCharacter else { return }
        
        alarmManager.scheduleAlarm(
            type: selectedAlarmType,
            character: character,
            time: selectedTime,
            weekdays: Array(selectedDays)
        )
        
        dismiss()
    }
}

@available(iOS 26.0, *)
struct AlarmTypeButton: View {
    let type: AlarmType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? 
                              LinearGradient(gradient: type.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 26.0, *)
struct WeekdayButton: View {
    let weekday: Locale.Weekday
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(weekday.rawValue.prefix(1).uppercased())
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .black : .white)
                .frame(width: 35, height: 35)
                .background(
                    Circle()
                        .fill(isSelected ? Color.orange : Color.gray.opacity(0.3))
                )
        }
    }
}

@available(iOS 26.0, *)
extension Locale {
    var orderedWeekdays: [Locale.Weekday] {
        let days: [Locale.Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        if let firstDayIdx = days.firstIndex(of: firstDayOfWeek), firstDayIdx != 0 {
            return Array(days[firstDayIdx...] + days[0..<firstDayIdx])
        }
        return days
    }
}

 
