import Foundation
import AVFoundation

class ElevenLabsManager: NSObject, ObservableObject {
    static let shared = ElevenLabsManager()
    
    // IMPORTANT: Move this to a secure location in production
    private let apiKey = "sk_718429774ae8d84a76e209e237172d4682f2be00995b05e0"
    @Published var currentCharacter: Character = Character.allCharacters[0]
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isSpeaking = false
    @Published var isLoading = false
    
    private let audioCache = AudioCacheManager()
    @Published var cacheHitRate: Double = 0.0
    private var totalRequests = 0
    private var cacheHits = 0
    
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
        
        totalRequests += 1
        
        // Stop any current playback
        audioPlayer?.stop()
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.isSpeaking = true
        }
        
        // Check cache first
        if let cachedAudio = audioCache.getCachedAudio(for: text, character: currentCharacter) {
            cacheHits += 1
            updateCacheHitRate()
            print("Using cached audio for roast")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            playAudio(data: cachedAudio)
            return
        }
        
        // Generate via API if not cached
        generateAndCacheAudio(for: text)
    }
    
    private func generateAndCacheAudio(for text: String) {
        // Create the request
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(currentCharacter.voiceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        // Configure voice settings based on character
        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": currentCharacter.voiceSettings.stability,
                "similarity_boost": currentCharacter.voiceSettings.similarityBoost,
                "style": currentCharacter.voiceSettings.style,
                "use_speaker_boost": currentCharacter.voiceSettings.speakerBoost
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
            
            guard let data = data, let strongSelf = self else {
                print("No audio data received")
                DispatchQueue.main.async {
                    self?.isSpeaking = false
                }
                return
            }
            
            // Cache the audio for future use
            strongSelf.audioCache.cacheAudio(data, for: text, character: strongSelf.currentCharacter)
            print("Generated and cached new audio for roast")
            
            // Play the audio
            strongSelf.playAudio(data: data)
        }.resume()
    }
    
    private func updateCacheHitRate() {
        cacheHitRate = totalRequests > 0 ? Double(cacheHits) / Double(totalRequests) : 0.0
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
    
    // MARK: - Cache Management
    
    func getCacheStats() -> (size: String, hitRate: String, totalRequests: Int) {
        let hitRatePercent = String(format: "%.1f%%", cacheHitRate * 100)
        return (audioCache.getCacheSize(), hitRatePercent, totalRequests)
    }
    
    func clearCache() {
        audioCache.clearCache()
        cacheHits = 0
        totalRequests = 0
        cacheHitRate = 0.0
    }
    
    // MARK: - Pre-generation for Common Scenarios
    
    func preGenerateCommonRoasts(for character: Character, completion: @escaping (Int, Int) -> Void) {
        let scenarios = RoastCache.suggestedPreGeneration
        var completed = 0
        let total = scenarios.count
        
        for scenario in scenarios {
            if let cachedRoast = RoastCache.getCachedRoast(
                for: character,
                stepCount: scenario.stepCount,
                calories: scenario.calories,
                duration: scenario.duration
            ) {
                // Check if we already have this audio cached
                if audioCache.getCachedAudio(for: cachedRoast, character: character) == nil {
                    // Generate and cache this roast
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(completed) * 0.5) {
                        self.generateAndCacheAudio(for: cachedRoast)
                        completed += 1
                        completion(completed, total)
                    }
                } else {
                    completed += 1
                    completion(completed, total)
                }
            } else {
                completed += 1
                completion(completed, total)
            }
        }
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
