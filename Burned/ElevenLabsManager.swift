import Foundation
import RevenueCat
import AVFoundation
import AIProxy

class ElevenLabsManager: NSObject, ObservableObject {
    static let shared = ElevenLabsManager()
    
    private let elevenLabsService = AIProxy.elevenLabsService(
        partialKey: "v2|d60c9395|0WN6S4AYSm-uMmAu",
        serviceURL: "https://api.aiproxy.com/840c1a83/357601f0"
    )
    @Published var currentCharacter: Character = Character.allCharacters[0]
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isSpeaking = false
    @Published var isLoading = false
    
    private let audioCache = AudioCacheManager()
    @Published var cacheHitRate: Double = 0.0
    private var totalRequests = 0
    private var cacheHits = 0
    @Published var dailyRoastCount = 0
    private var lastResetDate = Date()
    
    private override init() {
        super.init()
        setupAudioSession()
        loadDailyUsage()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func speakRoast(_ text: String, isPreview: Bool = false) {
        print("🎤 speakRoast called - isPreview: \(isPreview)")
        print("📝 Text: \(text)")
        print("🎭 Current character: \(currentCharacter.name)")
        
        guard !text.isEmpty else { 
            print("❌ Empty text provided")
            return 
        }
        
        // Skip daily limit check here since it's done in HomeTab asynchronously
        print("📊 Current daily count: \(dailyRoastCount)/5")
        
        // Increment usage for non-preview, non-premium roasts
        if !isPreview {
            print("📈 Incrementing daily usage")
            incrementDailyUsage()
        }
        
        print("🔢 Total requests: \(totalRequests + 1)")
        totalRequests += 1
        
        // Stop any current playback
        audioPlayer?.stop()
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.isSpeaking = true
        }
        
        // Check cache first
        print("🔍 Checking cache for text and character...")
        if let cachedAudio = audioCache.getCachedAudio(for: text, character: currentCharacter) {
            print("✅ Cache HIT - playing cached audio")
            cacheHits += 1
            updateCacheHitRate()
            print("Using cached audio for roast")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            playAudio(data: cachedAudio)
            return
        }
        
        print("❌ Cache MISS - generating new audio via API")
        // Generate via API if not cached
        generateAndCacheAudio(for: text)
    }
    
    private func generateAndCacheAudio(for text: String) {
        print("🌐 Making API call to ElevenLabs via AIProxy...")
        print("🎭 Using voice ID: \(currentCharacter.voiceId)")
        
        Task {
            do {
                let body = ElevenLabsTTSRequestBody(
                    text: text,
                    voiceSettings: .init(
                        similarityBoost: currentCharacter.voiceSettings.similarityBoost, stability: currentCharacter.voiceSettings.stability,
                        speakerBoost: currentCharacter.voiceSettings.speakerBoost, style: currentCharacter.voiceSettings.style
                    )
                )
                
                let mpegData = try await elevenLabsService.ttsRequest(
                    voiceID: currentCharacter.voiceId,
                    body: body, secondsToWait: UInt(5)
                )
                
                print("✅ Successfully generated audio via AIProxy")
                
                // Cache the audio for future use
                audioCache.cacheAudio(mpegData, for: text, character: currentCharacter)
                print("💾 Generated and cached new audio for roast")
                
                // Play the audio on main thread
                await MainActor.run {
                    isLoading = false
                    playAudio(data: mpegData)
                }
                
            } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
                print("❌ ElevenLabs API error: \(statusCode) - \(responseBody)")
                await MainActor.run {
                    isLoading = false
                    isSpeaking = false
                }
            } catch {
                print("❌ Could not create ElevenLabs TTS audio: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    isSpeaking = false
                }
            }
        }
    }
    
    private func updateCacheHitRate() {
        cacheHitRate = totalRequests > 0 ? Double(cacheHits) / Double(totalRequests) : 0.0
    }
    
    private func playAudio(data: Data) {
        print("📊 Memory before audio playback:")
        logMemoryAndCacheStatus()
        
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.isSpeaking = true
            }
            
            print("📊 Memory after audio setup:")
            logMemoryAndCacheStatus()
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
    
    // MARK: - Daily Usage Tracking
    
    private func loadDailyUsage() {
        dailyRoastCount = UserDefaults.standard.integer(forKey: "dailyRoastCount")
        if let savedDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date {
            lastResetDate = savedDate
        }
        checkAndResetDailyLimit()
    }
    
    private func checkAndResetDailyLimit() {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            // New day - reset count
            dailyRoastCount = 0
            lastResetDate = Date()
            saveDailyUsage()
        }
    }
    
    private func saveDailyUsage() {
        UserDefaults.standard.set(dailyRoastCount, forKey: "dailyRoastCount")
        UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate")
    }
    
    func canGenerateRoast(completion: @escaping (Bool) -> Void) {
        checkAndResetDailyLimit()
        
        print("🔍 Checking premium status...")
        // Check premium status asynchronously to avoid blocking main thread
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            let hasPremium = customerInfo?.entitlements.active.keys.contains("premium") ?? false
            let canGenerate = hasPremium || (self?.dailyRoastCount ?? 0) < 5
            
            print("💎 Premium status: \(hasPremium)")
            print("📊 Daily count: \(self?.dailyRoastCount ?? 0)/5")
            print("✅ Can generate: \(canGenerate)")
            
            DispatchQueue.main.async {
                completion(canGenerate)
            }
        }
    }
    
    func incrementDailyUsage() {
        checkAndResetDailyLimit()
        
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            let hasPremium = customerInfo?.entitlements.active.keys.contains("premium") ?? false
            
            if !hasPremium {
                self?.dailyRoastCount += 1
                self?.saveDailyUsage()
            }
        }
    }
    
    // MARK: - Memory Management
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        }
        return 0
    }
    
    func logMemoryAndCacheStatus() {
        let memoryUsage = getMemoryUsage()
        let cacheSize = audioCache.getCacheSize()
        print("💾 Memory usage: \(String(format: "%.1f", memoryUsage))MB")
        print("🗄️ Audio cache size: \(cacheSize)")
        print("📈 Cache hit rate: \(String(format: "%.1f", cacheHitRate))%")
        print("🔢 Total requests: \(totalRequests), Cache hits: \(cacheHits)")
    }
}
