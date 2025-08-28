import Foundation

struct Character: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let voiceId: String
    let description: String
    let imageName: String
    let voiceSettings: VoiceSettings
    
    struct VoiceSettings: Equatable {
        let stability: Double
        let similarityBoost: Double
        let style: Double
        let speakerBoost: Bool
    }
    
    static let allCharacters = [
        Character(
            
            name: "Drill Sergeant",
            voiceId: "DGzg6RaUqxGRTHSBjfgF",
            description: "Tough love fitness coach",
            imageName: "drill",
            voiceSettings: VoiceSettings(
                stability: 0.5,
                similarityBoost: 0.75,
                style: 0.4,
                speakerBoost: true
            )
        ),
        Character(
            name: "British Narrator",
            voiceId: "WdZjiN0nNcik2LBjOHiv",
            description: "British nature narrator",
            imageName: "narrator",
            voiceSettings: VoiceSettings(
                stability: 0.7,
                similarityBoost: 0.8,
                style: 0.3,
                speakerBoost: true
            )
        ),
        Character(
            name: "Your Ex",
            voiceId: "T7eLpgAAhoXHlrNajG8v",
            description: "That toxic ex who 'just wants to help'",
            imageName: "your_ex",
            voiceSettings: VoiceSettings(
                stability: 0.6,
                similarityBoost: 0.85,
                style: 0.5,
                speakerBoost: true
            )
        ),
        Character(
            name: "The Savage",
            voiceId: "DGzg6RaUqxGRTHSBjfgF", // Using drill sergeant voice for now
            description: "No mercy, no excuses, pure brutality",
            imageName: "savage",
            voiceSettings: VoiceSettings(
                stability: 0.4,
                similarityBoost: 0.9,
                style: 0.6,
                speakerBoost: true
            )
        )
    ]
}
