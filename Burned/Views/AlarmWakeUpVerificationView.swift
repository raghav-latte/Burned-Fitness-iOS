import SwiftUI
import Speech
import AVFoundation
import AlarmKit

@available(iOS 26.0, *)
struct AlarmWakeUpVerificationView: View {
    let alarmType: AlarmType
    let characterName: String
    let alarmID: String?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = WakeUpSpeechManager()
    @State private var isListening = false
    @State private var hasSucceeded = false
    @State private var showSuccess = false
    
    private var character: Character? {
        Character.allCharacters.first { $0.name == characterName }
    }
    
    private var wakeUpPhrase: String {
        let phrases: [String: String] = [
            "Drill Sergeant": "I'M AWAKE DRILL SERGEANT",
            "British Narrator": "I'M AWAKE SIR",
            "Your Ex (Female)": "I'M AWAKE AND BETTER WITHOUT YOU",
            "Your Ex (Male)": "I'M AWAKE BRO"
        ]
        return phrases[characterName] ?? "I'M AWAKE"
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Character display
                    characterSection
                    
                    // Wake up challenge
                    challengeSection
                    
                    // Speech recognition UI
                    speechSection
                    
                    // Audio level meter
                    audioMeterSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            
            // Success overlay
            if showSuccess {
                successOverlay
            }
        }
        .onAppear {
            speechManager.setup(targetPhrase: wakeUpPhrase, alarmType: alarmType)
        }
        .onDisappear {
            speechManager.cleanup()
        }
        .navigationBarHidden(true)
        .interactiveDismissDisabled(!hasSucceeded)
    }
    
    private var characterSection: some View {
        VStack(spacing: 16) {
            if let character = character {
                ZStack {
                    // Gradient mesh background like explore page
                    RadialGradient(
                        gradient: gradientForCharacter(character.name),
                        center: .center,
                        startRadius: 50,
                        endRadius: 220
                    )
                    
                    // Character image without circle clipping
                    Image(character.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 385)
                        .clipped()
                    
                    // Bottom fade for image like explore page
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.clear, Color.black, Color.black, Color.black]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 150)
                    }
                }
                .frame(height: 400)
                
                Text(character.name.uppercased())
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func gradientForCharacter(_ name: String) -> Gradient {
        switch name {
        case "Drill Sergeant":
            return Gradient(colors: [Color.green, Color.black])
        case "British Narrator":
            return Gradient(colors: [Color.blue, Color.black])
        case "Your Ex (Female)":
            return Gradient(colors: [Color.purple, Color.black])
        case "Your Ex (Male)":
            return Gradient(colors: [Color.indigo, Color.black])
        default:
            return Gradient(colors: [Color.gray, Color.black])
        }
    }
    
    private var challengeSection: some View {
        VStack(spacing: 20) {
            
            
            Text("Say this phrase LOUDLY")
                .font(.title)
                .foregroundColor(.white.opacity(0.9))
            
            Text("\"\(wakeUpPhrase)\"")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                )
        }
    }
    
    private var speechSection: some View {
        VStack(spacing: 20) {
            if !isListening && !hasSucceeded {
                Button(action: startListening) {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                        Text("START SPEAKING")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                }
            }
            
            if isListening {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "waveform")
                            .font(.title2)
                            .foregroundColor(.red)
                        Text("LISTENING...")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    if !speechManager.recognizedText.isEmpty {
                        Text("You said: \"\(speechManager.recognizedText)\"")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            
            if speechManager.matchProgress > 0 {
                VStack(spacing: 8) {
                    Text("Match Progress")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    ProgressView(value: speechManager.matchProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(x: 1, y: 2)
                }
            }
        }
    }
    
    private var audioMeterSection: some View {
        VStack(spacing: 12) {
            Text("Volume Level")
                .font(.headline)
                .foregroundColor(.white)
            
            // Decibel meter
            HStack(spacing: 4) {
                ForEach(0..<20, id: \.self) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(width: 12, height: barHeight(for: 1))
                        .opacity(speechManager.audioLevel > Float(index) / 20.0 ? 1.0 : 0.3)
                }
            }
            .frame(height: 60)
            
            HStack {
                Text("Quiet")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("LOUD!")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(showSuccess ? 1.2 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccess)
                
                Text("WELL DONE!")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text("You're officially awake!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Button("Continue") {
                    dismiss()
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
            }
        }
    }
    
    private func barColor(for index: Int) -> Color {
        let ratio = Float(index) / 20.0
        if ratio < 0.5 {
            return .green
        } else if ratio < 0.8 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        return CGFloat(20 + index * 2) // Bars get taller
    }
    
    private func startListening() {
        isListening = true
        speechManager.startListening { success in
            if success {
                withAnimation(.spring()) {
                    hasSucceeded = true
                    showSuccess = true
                }
                
                if let alarmID = alarmID, let uuid = UUID(uuidString: alarmID) {
                    try? AlarmManager.shared.stop(id: uuid)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if hasSucceeded {
                        dismiss()
                    }
                }
            } else {
                isListening = false
            }
        }
    }
}

@available(iOS 26.0, *)
class WakeUpSpeechManager: NSObject, ObservableObject {
    @Published var recognizedText = ""
    @Published var audioLevel: Float = 0.0
    @Published var matchProgress: Float = 0.0
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var targetPhrase = ""
    private var alarmType: AlarmType = .wakeUp
    
    private let requiredVolumeThreshold: Float = 0.6 // 60% volume required
    
    override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    func setup(targetPhrase: String, alarmType: AlarmType) {
        self.targetPhrase = targetPhrase.lowercased()
        self.alarmType = alarmType
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                // Handle authorization
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // Handle microphone permission
        }
    }
    
    func startListening(completion: @escaping (Bool) -> Void) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            completion(false)
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.checkMatch(completion: completion)
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
            
            // Calculate audio level
            let channelData = buffer.floatChannelData?[0]
            let channelDataValue = channelData?.pointee ?? 0
            let channelDataValueArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
            let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)
            let normalizedPower = max(0, (avgPower + 80) / 80) // Normalize -80dB to 0dB to 0-1
            
            DispatchQueue.main.async {
                self.audioLevel = min(normalizedPower, 1.0)
            }
        }
        
        try? audioEngine.start()
        
        // Auto-timeout after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.audioEngine.isRunning {
                completion(false)
            }
        }
    }
    
    private func checkMatch(completion: @escaping (Bool) -> Void) {
        let recognizedLower = recognizedText.lowercased()
        let targetWords = targetPhrase.components(separatedBy: " ")
        let recognizedWords = recognizedLower.components(separatedBy: " ")
        
        print("🎤 User said: '\(recognizedText)'")
        print("🎯 Target phrase: '\(targetPhrase)'")
        print("🔊 Audio level: \(audioLevel) (need \(requiredVolumeThreshold))")
        
        var matchedWords = 0
        for word in targetWords {
            if recognizedWords.contains(word) {
                matchedWords += 1
            }
        }
        
        let progress = Float(matchedWords) / Float(targetWords.count)
        matchProgress = progress
        
        print("✅ Match progress: \(Int(progress * 100))% (\(matchedWords)/\(targetWords.count) words)")
        
        // Check if phrase matches and volume is loud enough
        let phraseMatch = progress >= 0.8 // 80% word match
        let volumeMatch = audioLevel >= requiredVolumeThreshold
        
        print("📊 Phrase match: \(phraseMatch), Volume match: \(volumeMatch)")
        
        if phraseMatch && volumeMatch {
            print("🎉 CHALLENGE PASSED!")
            completion(true)
        }
    }
    
    func cleanup() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
}

@available(iOS 26.0, *)
extension WakeUpSpeechManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        AlarmWakeUpVerificationView(
            alarmType: .wakeUp,
            characterName: "Drill Sergeant",
            alarmID: nil
        )
    }
}
