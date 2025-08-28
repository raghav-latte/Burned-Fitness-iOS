import UIKit
import RevenueCat

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure RevenueCat
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        
        Purchases.configure(withAPIKey: "appl_JApjhjLxTOwitCcbEJOsIQQkavG")
        
        return true
    }
}