# Burned: Technical Specifications

## Architecture Overview

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   iOS Client    │    │  Third-Party    │    │   Apple Health │
│    (SwiftUI)    │◄──►│    Services     │    │     (HealthKit) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │              ┌─────────────────┐
         └──────────────►│   ElevenLabs    │
                        │      API        │
                        └─────────────────┘
                        ┌─────────────────┐
                        │   OneSignal     │
                        │      API        │
                        └─────────────────┘
```

## Frontend Architecture (iOS)

### Technology Stack
- **Framework**: SwiftUI (iOS 14.0+)
- **Language**: Swift 5.7+
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **State Management**: Combine Framework + ObservableObject
- **Deployment Target**: iOS 14.0 minimum

### Key Components

#### 1. App Structure
```swift
BurnedApp.swift                 // App entry point and initialization
├── ContentView.swift          // Main tab container
├── Models/
│   └── Character.swift        // Voice character definitions
├── ViewModels/
│   └── CharacterViewModel.swift // Character selection logic
├── Views/
│   └── CharacterSelectionView.swift // Character picker UI
└── Managers/
    ├── HealthKitManager.swift    // Health data integration
    ├── ElevenLabsManager.swift   // Voice synthesis
    ├── NotificationManager.swift // Local notifications
    └── OneSignalManager.swift    // Push notifications
```

#### 2. Data Flow Architecture
```
User Interaction → View → ViewModel → Manager → External Service
                                   ↓
Health Data ← HealthKitManager ← HealthKit Framework
Voice Audio ← ElevenLabsManager ← ElevenLabs API
Notifications ← NotificationManager ← UserNotifications Framework
Push Notifications ← OneSignalManager ← OneSignal SDK
```

### Core Managers

#### HealthKitManager
- **Purpose**: Interface with Apple HealthKit for fitness data
- **Responsibilities**:
  - Request health data permissions
  - Fetch daily metrics (steps, calories, heart rate)
  - Monitor workout sessions
  - Retrieve 30-day workout history
  - Background health data processing

**Key Methods**:
```swift
func requestAuthorization()
func fetchTodaysData()
func getCurrentRoast() -> String
func checkForNewWorkoutAndNotify()
func fetchWorkoutHistory()
```

#### ElevenLabsManager
- **Purpose**: AI voice synthesis for character roasts
- **Responsibilities**:
  - Manage voice character settings
  - Convert text to speech via API
  - Handle audio playback
  - Manage loading and speaking states

**API Integration**:
```swift
// Request Configuration
URL: https://api.elevenlabs.io/v1/text-to-speech/{voice_id}
Method: POST
Headers: 
  - Content-Type: application/json
  - xi-api-key: {api_key}
```

**Voice Settings Per Character**:
```swift
struct VoiceSettings {
    let stability: Double        // 0.0-1.0
    let similarityBoost: Double  // 0.0-1.0  
    let style: Double           // 0.0-1.0
    let speakerBoost: Bool      // true/false
}
```

#### RoastGenerator
- **Purpose**: Generate contextual fitness roasts
- **Responsibilities**:
  - Analyze health metrics
  - Select appropriate roast based on performance
  - Character-specific roast customization
  - Multi-factor roast generation

**Roast Categories**:
- No workout roasts (when user hasn't exercised)
- Duration-based roasts (short workouts)
- Heart rate roasts (low intensity)
- Calorie roasts (minimal burn)
- Pace roasts (slow running)
- Step count roasts (low activity)
- Character-specific roasts (especially "Your Ex")

## Data Models

### Character Model
```swift
struct Character: Identifiable, Equatable {
    let id: UUID
    let name: String
    let voiceId: String          // ElevenLabs voice ID
    let description: String
    let imageName: String
    let voiceSettings: VoiceSettings
}
```

### WorkoutData Model
```swift
struct WorkoutData {
    let duration: TimeInterval
    let distance: Double
    let heartRate: Double
    let calories: Double
    let workoutType: String
}
```

### WorkoutHistoryItem Model
```swift
struct WorkoutHistoryItem: Identifiable {
    let id: UUID
    let date: Date
    let workoutType: String
    let duration: TimeInterval
    let distance: Double
    let heartRate: Double
    let calories: Double
}
```

## Third-Party Integrations

### ElevenLabs API
- **Service**: Text-to-Speech voice synthesis
- **Pricing**: Pay-per-use model (~$0.30 per 1K characters)
- **Rate Limits**: 2 requests per second (free tier)
- **Voice Quality**: Professional-grade AI voices
- **Latency**: ~2-3 seconds response time

**Character Voice Mappings**:
```swift
"Drill Sergeant" → "DGzg6RaUqxGRTHSBjfgF"
"British Narrator" → "WdZjiN0nNcik2LBjOHiv"  
"Your Ex" → "T7eLpgAAhoXHlrNajG8v"
```

### OneSignal Push Notifications
- **Service**: Cross-platform push notification delivery
- **Features**: 
  - Scheduled notifications
  - User segmentation
  - A/B testing capabilities
  - Rich media support
- **Integration**: iOS SDK with automatic setup

### Apple HealthKit
- **Framework**: Native iOS health data access
- **Permissions Required**:
  - Step Count (HKQuantityType.stepCount)
  - Heart Rate (HKQuantityType.heartRate)  
  - Workout Sessions (HKObjectType.workoutType)
  - Sleep Analysis (HKCategoryType.sleepAnalysis)
  - Active Energy Burned (HKQuantityType.activeEnergyBurned)
  - Distance Walking/Running (HKQuantityType.distanceWalkingRunning)

**Data Fetching Strategy**:
- Real-time queries for current day metrics
- Historical queries for workout analysis
- Background app refresh for workout detection

## Background Processing

### iOS Background Tasks
```swift
BGTaskScheduler Identifier: "com.niyat.Burned.workout-check"
Frequency: Every 4 hours
Purpose: Detect new workouts and trigger notifications
```

### Background Workflow
1. System triggers background refresh
2. HealthKitManager fetches latest workout data
3. Compare with previous workout state
4. Generate appropriate roast (workout or no-workout)
5. Schedule local notification
6. Update app state for next launch

## Security & Privacy

### API Key Management
```swift
// Current Implementation (Development)
private let apiKey = "sk_718429774ae8d84a76e209e237172d4682f2be00995b05e0"

// Production Implementation (Recommended)
private let apiKey = Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_API_KEY") as? String
```

### Health Data Privacy
- **Local Processing**: All health data analysis performed on-device
- **Minimal Cloud Transmission**: Only roast text sent to ElevenLabs
- **User Consent**: Explicit HealthKit permission requests
- **Data Retention**: No long-term health data storage

### User Privacy Controls
- **Roast Intensity**: 5-level scale (gentle to savage)
- **Notification Frequency**: User-configurable timing
- **Character Selection**: Full control over voice personality
- **Data Sharing**: Optional social media integration

## Performance Considerations

### Audio Caching Strategy
```swift
// Current: No caching (fresh API calls)
// Recommended: Implement audio file caching for repeated roasts
class AudioCache {
    private var cache: [String: Data] = [:]
    func cacheAudio(for text: String, data: Data)
    func getCachedAudio(for text: String) -> Data?
}
```

### HealthKit Query Optimization
- **Batch Queries**: Minimize individual API calls
- **Predicate Filtering**: Date range and sample type restrictions
- **Background Limits**: Respect iOS background execution time limits

### Memory Management
- **Weak References**: Prevent retain cycles in closures
- **Audio Player Cleanup**: Proper AVAudioPlayer disposal
- **Large Data Handling**: Stream workout history instead of loading all at once

## Development Environment

### Build Configuration
```yaml
Development:
  Bundle ID: com.niyat.Burned
  Team ID: Developer Team ID
  Provisioning: Development Profile
  Signing: Automatic

Production:
  Bundle ID: com.niyat.Burned
  Team ID: Distribution Team ID  
  Provisioning: App Store Profile
  Signing: Manual
```

### Dependencies
```swift
// Package.swift dependencies
dependencies: [
    .package(url: "https://github.com/OneSignal/OneSignal-iOS-SDK", from: "3.0.0")
]

// Manual Integrations
- ElevenLabs API (REST API calls)
- HealthKit Framework (Native iOS)
- AVFoundation (Audio playback)
- UserNotifications (Local notifications)
```

## Testing Strategy

### Unit Testing
- **RoastGenerator**: Test roast selection logic
- **HealthKitManager**: Mock health data scenarios
- **ElevenLabsManager**: API response handling
- **Character Models**: Data validation

### Integration Testing
- **HealthKit Permissions**: Authorization flow
- **Audio Playback**: End-to-end voice synthesis
- **Background Tasks**: Workout detection accuracy
- **Notification Delivery**: Local and push notifications

### UI Testing
- **Tab Navigation**: User flow between screens
- **Character Selection**: Voice preview functionality
- **Settings Configuration**: Preference persistence
- **Accessibility**: VoiceOver support

## Deployment Pipeline

### App Store Requirements
- **iOS Version Support**: iOS 14.0+
- **Device Compatibility**: iPhone and iPad
- **App Store Categories**: Health & Fitness, Entertainment
- **Content Rating**: 12+ (Mild Language, Simulated Gambling)

### Release Process
1. **Development Build**: Internal testing and validation
2. **TestFlight Beta**: External user testing program
3. **App Store Review**: Apple review process (7-14 days)
4. **Production Release**: Public app store availability

### Monitoring & Analytics
- **Crash Reporting**: Xcode Organizer / Crashlytics
- **Usage Analytics**: Custom event tracking
- **Performance Monitoring**: App launch time, API response times
- **User Feedback**: App Store reviews and in-app feedback

## Scalability Considerations

### API Cost Management
```swift
// ElevenLabs cost optimization
- Character count limits per user
- Audio caching for repeated roasts
- Batch processing for multiple roasts
- Usage analytics and cost monitoring
```

### User Base Growth
- **Background Task Limits**: iOS system limitations on background refresh
- **Notification Rate Limits**: OneSignal delivery quotas
- **HealthKit Query Performance**: Optimize for large user bases
- **Server Infrastructure**: Future backend API considerations

### Feature Expansion
- **Additional Characters**: Scalable voice character system
- **Cross-Platform**: Android development considerations
- **Wearable Integration**: Apple Watch and fitness tracker support
- **Social Features**: User-generated content and sharing capabilities

## Future Technical Roadmap

### Phase 1 Improvements
- Audio caching system implementation
- Background processing optimization
- Enhanced error handling and retry logic
- Performance monitoring integration

### Phase 2 Enhancements  
- Custom voice character creation
- Advanced health data analysis (trends, patterns)
- Machine learning for personalized roast selection
- Social sharing and community features

### Phase 3 Platform Expansion
- Android application development
- Web dashboard for detailed analytics
- API backend for user data synchronization
- Enterprise/corporate wellness integration

## Risk Mitigation

### Technical Risks
1. **ElevenLabs API Downtime**
   - Fallback to cached audio files
   - Alternative TTS service integration
   - Graceful degradation with text-only mode

2. **iOS Background Limitations**
   - Optimize background execution time
   - Implement push notification fallbacks
   - User education on background refresh settings

3. **HealthKit Data Availability**
   - Handle missing or incomplete data gracefully
   - Provide manual data entry options
   - Clear user guidance on data permissions

### Operational Risks
1. **High API Costs**
   - Implement usage quotas per user
   - Optimize character count in roasts
   - Consider premium tier restrictions

2. **App Store Rejection**
   - Content review and moderation
   - Compliance with App Store guidelines
   - Age rating and content warnings

3. **User Privacy Concerns**
   - Transparent data usage policies
   - Minimal data collection approach
   - User control over all privacy settings