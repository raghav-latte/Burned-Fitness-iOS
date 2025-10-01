import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleWorkoutRoast(roast: String) {
        let content = UNMutableNotificationContent()
        content.title = "Burned 🔥"
        content.body = roast
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "workout-roast-\(UUID())", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleDailyNoWorkoutRoast() {
        let content = UNMutableNotificationContent()
        content.title = "Burned 🔥"
        content.body = "Still waiting for that workout... Your couch misses you less than I do."
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-no-workout-roast", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            }
        }
    }
    
    func scheduleBackgroundWorkoutCheck() {
        let brutaDailyRoasts = [
            "Day 2 of no workout. Your fitness tracker is considering therapy.",
            "Still no workout? Even your shadow is more active than you.",
            "Your muscles are officially on strike.",
            "Breaking: Local person discovers new way to disappoint themselves daily.",
            "Your workout clothes are starting a missing person case.",
            "If inactivity was an art form, you'd be the Mona Lisa.",
            "Your gym membership is basically a monthly donation to disappointment.",
            "Even your reflection in the mirror is avoiding eye contact.",
            "Your heart rate monitor thinks it's unemployed.",
            "At this point, your couch should charge you rent."
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Still Burned 🔥💀"
        content.body = brutaDailyRoasts.randomElement() ?? "Your laziness is legendary."
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "brutal-daily-roast", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling brutal daily notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelDailyNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-no-workout-roast", "brutal-daily-roast"])
    }
    
    func scheduleCharacterWorkoutRoast(roast: String, characterName: String) {
        let content = UNMutableNotificationContent()
        
        // Character-specific notification titles and emojis
        switch characterName {
        case "Drill Sergeant":
            content.title = "🪖 DRILL SERGEANT REPORT"
        case "British Narrator":
            content.title = "🎙️ Fitness Observations"
        case "Your Ex (Female)":
            content.title = "💔 Your Ex Called"
        case "Your Ex (Male)":
            content.title = "💪 Your Ex Texted"
        case "The Savage":
            content.title = "🔥 BRUTAL BURN"
        default:
            content.title = "🔥 Burned"
        }
        
        content.body = roast
        content.sound = .default
        content.badge = 1
        
        // Add category for better notification handling
        content.categoryIdentifier = "WORKOUT_ROAST"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "character-workout-roast-\(UUID())", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling character workout notification: \(error)")
            } else {
                print("✅ Character workout notification sent: \(characterName)")
            }
        }
    }
    
    func sendTestNotification() {
        let testRoasts = [
            "Test roast: Your motivation is currently under construction... indefinitely.",
            "Test roast: Even your excuses are getting lazy at this point.",
            "Test roast: Your workout schedule is more mythical than unicorns.",
            "Test roast: If procrastination burned calories, you'd be dangerously underweight.",
            "Test roast: Your fitness journey is stuck in traffic... permanently.",
            "Test roast: Even your smartwatch is questioning its life choices.",
            "Test roast: Your dedication to avoiding exercise is truly inspiring.",
            "Test roast: You've mastered the art of disappointing yourself daily.",
            "Test roast: Your couch has Stockholm syndrome at this point.",
            "Test roast: Breaking news: Local person discovers new levels of laziness."
        ]
        
        let randomRoast = testRoasts.randomElement() ?? "Test notification working!"
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Test Burn"
        content.body = randomRoast
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test-roast-\(UUID())", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            } else {
                print("Test notification sent successfully!")
            }
        }
    }
}