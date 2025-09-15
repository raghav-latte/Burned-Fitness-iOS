import Foundation

@available(iOS 26.0, iPadOS 26.0, *)
struct UnifiedRoastGenerator {
    static func generateSavageRoast(prompt: String) async throws -> String {
        print("🔥 UNIFIED ROAST GENERATOR: Starting roast generation")
        print("📝 PROMPT: \(prompt)")
        
        if DeviceCapabilityManager.supportsFoundationModels() {
            print("🤖 USING: Foundation Model")
            let result = try await FoundationRoast.generate(savageRoastPrompt: prompt)
            print("✅ RESPONSE: \(result)")
            return result
        } else {
            let result = "Fallback savage roast: \(prompt)"
            print("🔄 USING: Fallback mode - \(result)")
            return result
        }
    }
}
