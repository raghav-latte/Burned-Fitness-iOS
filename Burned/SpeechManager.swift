import Foundation
import AVFoundation

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func speakRoast(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Add some pauses for dramatic effect
        let enhancedText = addDramaticPauses(text)
        let utterance = AVSpeechUtterance(string: enhancedText)
        
        // Configure voice settings for maximum sass
        utterance.rate = 0.5 // Slightly slower for dramatic effect
        utterance.pitchMultiplier = 0.9 // Slightly lower pitch for attitude
        utterance.volume = 1.0
        
        // Try to use a sassy voice if available
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
        
        synthesizer.speak(utterance)
    }
    
    private func addDramaticPauses(_ text: String) -> String {
        // Add pauses after certain phrases for dramatic effect
        let dramaticText = text
            .replacingOccurrences(of: "...", with: "... ... ...")
            .replacingOccurrences(of: "!", with: "! ... ")
            .replacingOccurrences(of: "?", with: "? ... ")
            .replacingOccurrences(of: ",", with: ", ... ")
        
        return dramaticText
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}