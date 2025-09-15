import Foundation
import FoundationModels
import UIKit

@available(iOS 26.0, iPadOS 26.0, *)
struct DeviceCapabilityManager {
    private static var model = SystemLanguageModel.default
    
    static func supportsFoundationModels() -> Bool {
        print("🔍 DIAGNOSTIC: Checking FoundationModels framework availability...")
        print("📱 iOS Version: \(UIDevice.current.systemVersion)")
        print("📱 Device Model: \(UIDevice.current.model)")
        print("🤖 Model Type: \(model)")
        
        switch model.availability {
        case .available:
            print("✅ FOUNDATION MODEL STATUS: AVAILABLE")
            print("🎯 Using SystemLanguageModel: \(model)")
            print("🚀 AI features will be enabled")
            return true
        case .unavailable:
            print("❌ FOUNDATION MODEL STATUS: UNAVAILABLE - Using fallback")
            print("📱 Device does not support FoundationModels framework")
            print("🔄 Using library-based roast generation")
            return false
        }
    }
}
