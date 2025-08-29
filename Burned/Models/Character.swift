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
             description: "Military-grade motivation with zero tolerance for excuses",
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
             description: "Documentary-style commentary on your pathetic fitness journey",
            imageName: "narrator",
            voiceSettings: VoiceSettings(
                stability: 0.7,
                similarityBoost: 0.8,
                style: 0.3,
                speakerBoost: true
            )
        ),
        Character(
            name: "Your Ex (Female)",
            voiceId: "T7eLpgAAhoXHlrNajG8v",
            description: "Sweet-talking saboteur who remembers every workout you skipped",
            imageName: "female-ex",
            voiceSettings: VoiceSettings(
                stability: 0.6,
                similarityBoost: 0.85,
                style: 0.5,
                speakerBoost: true
            )
        ),
        Character(
            name: "Your Ex (Male)",
            voiceId: "cgLpYGyXZhkyalKZ0xeZ",
            description: "Mansplaining fitness bro who still thinks he's your personal trainer",
            imageName: "male-ex",
            voiceSettings: VoiceSettings(
                stability: 0.5,
                similarityBoost: 0.8,
                style: 0.6,
                speakerBoost: true
            )
        )
    ]
}
