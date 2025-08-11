import Foundation
import AVFoundation

class ElevenLabsManager: NSObject, ObservableObject {
    static let shared = ElevenLabsManager()
    
    // IMPORTANT: Move this to a secure location in production
    private let apiKey = "sk_718429774ae8d84a76e209e237172d4682f2be00995b05e0"
    private let voiceId = "DGzg6RaUqxGRTHSBjfgF" // Drill seargent voice - sassy and clear
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isSpeaking = false
    @Published var isLoading = false
    
    private override init() {
        super.init()
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
        
        // Stop any current playback
        audioPlayer?.stop()
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.isSpeaking = true
        }
        
        // Create the request
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        // Configure voice settings for maximum sass
        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.75,
                "style": 0.4,
                "use_speaker_boost": true
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to encode request body: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.isSpeaking = false
            }
            return
        }
        
        // Make the request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("ElevenLabs API error: \(error)")
                DispatchQueue.main.async {
                    self?.isSpeaking = false
                }
                return
            }
            
            guard let data = data else {
                print("No audio data received")
                DispatchQueue.main.async {
                    self?.isSpeaking = false
                }
                return
            }
            
            // Play the audio
            self?.playAudio(data: data)
        }.resume()
    }
    
    private func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.isSpeaking = true
            }
        } catch {
            print("Failed to play audio: \(error)")
            DispatchQueue.main.async {
                self.isSpeaking = false
            }
        }
    }
    
    func stopSpeaking() {
        audioPlayer?.stop()
        isSpeaking = false
    }
}

// MARK: - AVAudioPlayerDelegate
extension ElevenLabsManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown")")
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
