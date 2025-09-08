import Foundation
import AlarmKit
import SwiftUI
import AppIntents
import ActivityKit

@available(iOS 26.0, *)
@Observable class BurnedAlarmManager {
    static let shared = BurnedAlarmManager()
    
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<BurnedAlarmMetadata>
    typealias AlarmsMap = [UUID: (Alarm, AlarmType, String)]
    
    @MainActor var alarmsMap = AlarmsMap()
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @MainActor var hasAlarms: Bool {
        !alarmsMap.isEmpty
    }
    
    init() {
        observeAlarms()
    }
    
    func fetchAlarms() {
        do {
            let remoteAlarms = try alarmManager.alarms
            updateAlarmState(with: remoteAlarms)
        } catch {
            print("Error fetching alarms: \(error)")
        }
    }
    
    func scheduleAlarm(type: AlarmType, character: Character, time: Date, weekdays: [Locale.Weekday] = []) {
        let attributes = AlarmAttributes(
            presentation: alarmPresentation(for: type, character: character),
            metadata: BurnedAlarmMetadata(alarmType: type, characterName: character.name),
            tintColor: tintColor(for: type)
        )
        
        let id = UUID()
        let schedule = createSchedule(for: time, weekdays: weekdays)
        
        let countdownDuration = type == .workout 
            ? Alarm.CountdownDuration(preAlert: 10, postAlert: 60) // 10 sec prep, 60 sec rest
            : nil
        
        let secondaryIntent: (any LiveActivityIntent)? = type == .workout 
            ? BurnedRepeatIntent(alarmID: id.uuidString)
            : nil
        
        let sound = customSound(for: type)
        
        let alarmConfiguration: AlarmConfiguration
         alarmConfiguration = try AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: schedule,
            attributes: attributes,
            stopIntent: BurnedOpenAppIntent(alarmID: id.uuidString),
            secondaryIntent: secondaryIntent,
            sound: sound
        )
        scheduleAlarm(id: id, type: type, characterName: character.name, configuration: alarmConfiguration)
    }
    
    func unscheduleAlarm(with alarmID: UUID) {
        try? alarmManager.cancel(id: alarmID)
        Task { @MainActor in
            alarmsMap[alarmID] = nil
        }
    }
    
    private func scheduleAlarm(id: UUID, type: AlarmType, characterName: String, configuration: AlarmConfiguration) {
        Task {
            do {
                guard await requestAuthorization() else {
                    print("Not authorized to schedule alarms.")
                    return
                }
                let alarm = try await alarmManager.schedule(id: id, configuration: configuration)
                await MainActor.run {
                    alarmsMap[id] = (alarm, type, characterName)
                }
            } catch {
                print("Error scheduling alarm: \(error)")
            }
        }
    }
    
    private func alarmPresentation(for type: AlarmType, character: Character) -> AlarmPresentation {
        let title = motivationalTitle(for: type, character: character)
        
        if type == .workout {
            // Workout alarms get countdown functionality
            let alertContent = AlarmPresentation.Alert(
                title: title,
                stopButton: .stopButton,
                secondaryButton: .repeatButton,
                secondaryButtonBehavior: .countdown
            )
            
            let countdownContent = AlarmPresentation.Countdown(
                title: "GET PUMPED! \(character.emoji)",
                pauseButton: .pauseButton
            )
            
            let pausedContent = AlarmPresentation.Paused(
                title: "Rest Time Over",
                resumeButton: .resumeButton
            )
            
            return AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: pausedContent)
        } else {
            // Wake up and sleep alarms only have open app button - no stop button
            let alertContent = AlarmPresentation.Alert(
                title: title,
                stopButton: .openAppButton,
                secondaryButton: nil,
                secondaryButtonBehavior: .custom
            )
            
            return AlarmPresentation(alert: alertContent)
        }
    }
    
    private func motivationalTitle(for type: AlarmType, character: Character) -> LocalizedStringResource {
        let messages: [AlarmType: [String: String]] = [
            .wakeUp: [
                "Drill Sergeant": "WAKE UP, MAGGOT! TIME TO DOMINATE!",
                "British Narrator": "Rise and shine, sleeping beauty",
                "Your Ex (Female)": "Remember when you used to wake up early?",
                "Your Ex (Male)": "Bro, even your alarm is disappointed"
            ],
            .workout: [
                "Drill Sergeant": "DROP AND GIVE ME TWENTY!",
                "British Narrator": "Time for your daily dose of regret",
                "Your Ex (Female)": "Working out without me? How original",
                "Your Ex (Male)": "Still need me to motivate you, huh?"
            ],
            .sleep: [
                "Drill Sergeant": "LIGHTS OUT, SOLDIER!",
                "British Narrator": "Even your pillow is tired of waiting",
                "Your Ex (Female)": "Sweet dreams... if you can manage them",
                "Your Ex (Male)": "Finally going to bed at a decent time?"
            ]
        ]
        
        let message = messages[type]?[character.name] ?? type.description
        return LocalizedStringResource(stringLiteral: message)
    }
    
    private func tintColor(for type: AlarmType) -> Color {
        switch type {
        case .wakeUp: return .orange
        case .workout: return .red
        case .sleep: return .blue
        }
    }
    
    private func customSound(for type: AlarmType) -> AlertConfiguration.AlertSound {
        // Check if the audio file exists in the main bundle
        guard Bundle.main.path(forResource: type.soundFileName.replacingOccurrences(of: ".mp3", with: ""), ofType: "mp3") != nil else {
            print("⚠️ Custom sound file '\(type.soundFileName)' not found in bundle. Using default alarm sound.")
            return AlertConfiguration.AlertSound.default
        }
        
        // Create custom sound with looping for the alarm
        print("🔊 Attempting to create looping sound for \(type.soundFileName)")
        
        // Try creating a looping sound - test different API variations
        let sound = AlertConfiguration.AlertSound.named(type.soundFileName)
        print("✅ Created basic sound, checking if it loops by default...")
        
        return sound
    }
    
    private func createSchedule(for time: Date, weekdays: [Locale.Weekday]) -> Alarm.Schedule {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let alarmTime = Alarm.Schedule.Relative.Time(
            hour: components.hour ?? 7,
            minute: components.minute ?? 0
        )
        
        if weekdays.isEmpty {
            // One-time alarm
            return .relative(.init(time: alarmTime))
        } else {
            // Weekly recurring alarm
            return .relative(.init(time: alarmTime, repeats: .weekly(weekdays)))
        }
    }
    
    private func observeAlarms() {
        Task {
            for await incomingAlarms in alarmManager.alarmUpdates {
                updateAlarmState(with: incomingAlarms)
            }
        }
    }
    
    private func updateAlarmState(with remoteAlarms: [Alarm]) {
        Task { @MainActor in
            remoteAlarms.forEach { updated in
                if let existing = alarmsMap[updated.id] {
                    alarmsMap[updated.id] = (updated, existing.1, existing.2)
                } else {
                    // Handle old alarms from previous sessions
                    alarmsMap[updated.id] = (updated, .wakeUp, "Unknown")
                }
            }
            
            let knownAlarmIDs = Set(alarmsMap.keys)
            let incomingAlarmIDs = Set(remoteAlarms.map(\.id))
            let removedAlarmIDs = knownAlarmIDs.subtracting(incomingAlarmIDs)
            
            removedAlarmIDs.forEach {
                alarmsMap[$0] = nil
            }
        }
    }
    
    private func requestAuthorization() async -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            do {
                let state = try await alarmManager.requestAuthorization()
                return state == .authorized
            } catch {
                print("Error requesting authorization: \(error)")
                return false
            }
        case .denied: return false
        case .authorized: return true
        @unknown default: return false
        }
    }
}

// MARK: - App Intents
@available(iOS 26.0, *)
struct BurnedStopIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.stop(id: UUID(uuidString: alarmID)!)
        return .result()
    }
    
    static var title: LocalizedStringResource = "Stop Alarm"
    static var description = IntentDescription("Stop the alarm")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
}

@available(iOS 26.0, *)
struct BurnedOpenAppIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        // Don't stop the alarm here - let the verification view handle it
        
        // Create URL to open app with alarm verification data
        Task { @MainActor in
            if let alarmData = getAlarmData() {
                let urlString = "burned://alarm?type=\(alarmData.type.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&character=\(alarmData.characterName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&alarmID=\(alarmID)"
                print("🚨 Opening app with URL: \(urlString)")
                if let url = URL(string: urlString) {
                    await UIApplication.shared.open(url)
                }
            } else {
                print("🚨 No alarm data found, opening app normally")
                if let url = URL(string: "burned://") {
                    await UIApplication.shared.open(url)
                }
            }
        }
        
        return .result()
    }
    
    static var title: LocalizedStringResource = "Open Burned"
    static var description = IntentDescription("Open the Burned app with wake-up challenge")
    static var openAppWhenRun = true
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    @MainActor
    private func getAlarmData() -> (type: AlarmType, characterName: String)? {
        guard let uuid = UUID(uuidString: alarmID),
              let alarmData = BurnedAlarmManager.shared.alarmsMap[uuid] else {
            return nil
        }
        
        return (type: alarmData.1, characterName: alarmData.2)
    }
}

@available(iOS 26.0, *)

struct BurnedRepeatIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.countdown(id: UUID(uuidString: alarmID)!)
        return .result()
    }
    
    static var title: LocalizedStringResource = "Repeat Workout"
    static var description = IntentDescription("Start another workout countdown")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
}

@available(iOS 26.0, *)
struct BurnedPauseIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.pause(id: UUID(uuidString: alarmID)!)
        return .result()
    }
    
    static var title: LocalizedStringResource = "Pause"
    static var description = IntentDescription("Pause the countdown")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
}

@available(iOS 26.0, *)
struct BurnedResumeIntent: LiveActivityIntent {
    func perform() throws -> some IntentResult {
        try AlarmManager.shared.resume(id: UUID(uuidString: alarmID)!)
        return .result()
    }
    
    static var title: LocalizedStringResource = "Resume"
    static var description = IntentDescription("Resume the countdown")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
}

// MARK: - Extensions

@available(iOS 26.0, *)
extension AlarmButton {
    static var openAppButton: Self {
        AlarmButton(text: "Open Burned", textColor: .black, systemImageName: "flame.fill")
    }
    
    static var stopButton: Self {
        AlarmButton(text: "Stop", textColor: .white, systemImageName: "xmark.circle.fill")
    }
    
    static var repeatButton: Self {
        AlarmButton(text: "Repeat", textColor: .black, systemImageName: "repeat.circle.fill")
    }
    
    static var pauseButton: Self {
        AlarmButton(text: "Pause", textColor: .black, systemImageName: "pause.circle.fill")
    }
    
    static var resumeButton: Self {
        AlarmButton(text: "Resume", textColor: .black, systemImageName: "play.circle.fill")
    }
}
