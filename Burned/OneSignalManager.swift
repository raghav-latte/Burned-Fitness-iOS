import Foundation
import OneSignalFramework

class OneSignalManager: ObservableObject {
    static let shared = OneSignalManager()
    
    // Replace with your actual OneSignal App ID
    private let appId = "YOUR_ONESIGNAL_APP_ID_HERE"
    
    private init() {}
    
    func initialize() {
        // Remove this method and uncomment below after installing OneSignal SDK
        
        /*
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
        OneSignal.initialize(appId, withLaunchOptions: nil)
        
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
        */
        
        print("OneSignal would be initialized here with App ID: \(appId)")
    }
    
    func sendTestRoast() {
        // This would typically be called from your server
        // For testing, you can use OneSignal Dashboard or REST API
        
        let testRoasts = [
            "OneSignal Test: Your motivation needs a GPS - it's completely lost!",
            "OneSignal Test: Even your excuses are getting tired of you.",
            "OneSignal Test: Your workout plan is more fictional than Marvel movies.",
            "OneSignal Test: If laziness was an Olympic sport, you'd win gold... eventually.",
            "OneSignal Test: Your couch is considering filing a restraining order."
        ]
        
        let randomRoast = testRoasts.randomElement() ?? "OneSignal test notification!"
        
        // In a real app, you'd call your backend API to send the notification
        sendNotificationViaAPI(message: randomRoast)
    }
    
    private func sendNotificationViaAPI(message: String) {
        // This is where you'd call your backend or OneSignal REST API
        print("Would send notification: \(message)")
        
        // Example OneSignal REST API call (you'd implement this in your backend):
        /*
        let notification = [
            "app_id": appId,
            "included_segments": ["Subscribed Users"],
            "headings": ["en": "🔥 Burned"],
            "contents": ["en": message],
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1
        ]
        
        // Make POST request to https://onesignal.com/api/v1/notifications
        */
    }
    
    func getUserId() -> String? {
        // Uncomment after OneSignal SDK is added
        // return OneSignal.User.onesignalId
        return "demo-user-id"
    }
}