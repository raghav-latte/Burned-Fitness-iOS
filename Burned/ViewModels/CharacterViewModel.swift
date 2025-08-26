import SwiftUI
import Combine

class CharacterViewModel: ObservableObject {
    @Published var selectedCharacter: Character?
    @Published var showCharacterSelection = false
    
    private let userDefaults = UserDefaults.standard
    private let selectedCharacterKey = "selectedCharacterVoiceId"
    
    init() {
        loadSelectedCharacter()
    }
    
    private func loadSelectedCharacter() {
        if let savedVoiceId = userDefaults.string(forKey: selectedCharacterKey),
           let character = Character.allCharacters.first(where: { $0.voiceId == savedVoiceId }) {
            selectedCharacter = character
            ElevenLabsManager.shared.currentCharacter = character
        } else {
            // Default to first character if none selected
            selectedCharacter = Character.allCharacters[0]
            ElevenLabsManager.shared.currentCharacter = Character.allCharacters[0]
        }
    }
    
    func selectCharacter(_ character: Character) {
        selectedCharacter = character
        ElevenLabsManager.shared.currentCharacter = character
        userDefaults.set(character.voiceId, forKey: selectedCharacterKey)
        showCharacterSelection = false
    }
    
    func shouldShowCharacterSelection() -> Bool {
        return selectedCharacter == nil || showCharacterSelection
    }
}