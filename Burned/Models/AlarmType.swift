import Foundation
import AlarmKit
import SwiftUI

@available(iOS 26.0, *)
enum AlarmType: String, CaseIterable, Codable {
    case wakeUp = "Wake Up"
    case workout = "Workout"
    case sleep = "Sleep"
    
    var icon: String {
        switch self {
        case .wakeUp: return "sun.rise.fill"
        case .workout: return "dumbbell.fill"
        case .sleep: return "moon.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .wakeUp: return "☀️"
        case .workout: return "💪"
        case .sleep: return "🌙"
        }
    }
    
    var description: String {
        switch self {
        case .wakeUp: return "Rise and shine with motivation"
        case .workout: return "Time to crush your fitness goals"
        case .sleep: return "Wind down for better rest"
        }
    }
    
    var gradient: Gradient {
        switch self {
        case .wakeUp:
            return Gradient(colors: [Color.orange, Color.yellow])
        case .workout:
            return Gradient(colors: [Color.red, Color.orange])
        case .sleep:
            return Gradient(colors: [Color.blue, Color.purple])
        }
    }
    
    var soundFileName: String {
        switch self {
        case .wakeUp:
            return "wakeup_alarm.mp3"
        case .workout:
            return "workout_alarm.mp3"
        case .sleep:
            return "sleep_alarm.mp3"
        }
    }
}

@available(iOS 26.0, *)
struct BurnedAlarmMetadata: AlarmMetadata, Codable {
    let createdAt: Date
    let alarmType: AlarmType
    let characterName: String
    
    init(alarmType: AlarmType, characterName: String) {
        self.createdAt = Date.now
        self.alarmType = alarmType
        self.characterName = characterName
    }
}