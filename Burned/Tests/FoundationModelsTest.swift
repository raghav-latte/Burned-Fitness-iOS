import Foundation

@available(iOS 26.0, iPadOS 26.0, *)
struct FoundationModelsTest {
    static func testRoastGeneration() async {
        let testPrompt = "User walked 5000 steps and burned 200 calories"
        
        do {
            let roast = try await UnifiedRoastGenerator.generateSavageRoast(prompt: testPrompt)
            print("✅ Generated roast: \(roast)")
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
