import Foundation
import FoundationModels

@available(iOS 26.0, iPadOS 26.0, *)
struct FoundationRoast: @unchecked Sendable {
    static func generate(savageRoastPrompt: String) async throws -> String {
        print("🤖 FOUNDATION ROAST GENERATOR: AI interaction starting")
        print("📋 INSTRUCTIONS: Generate a savage roast that is brutally honest, merciless, and emotionally devastating yet funny. Focus on fitness data and make it character-specific when possible. Keep it concise and impactful.")
        print("🔥 PROMPT: \(savageRoastPrompt)")
        
        let instructions = """
        Generate a savage roast that is brutally honest, merciless, and emotionally devastating yet funny.
        Focus on fitness data and make it character-specific when possible.
        Keep it concise and impactful.
        """
        
        let session = LanguageModelSession(instructions: instructions)
        print("🎯 AI SESSION: Created LanguageModelSession")
        
        let response = try await session.respond(to: savageRoastPrompt)
        print("🤖 AI RESPONSE: \(response.content)")
        print("✅ FOUNDATION ROAST: Generated successfully")
        
        return response.content
    }
}
