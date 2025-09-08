# AlarmKit Custom Audio Setup

## 📁 Required Audio Files

Add these MP3 files to your Xcode project's main bundle:

### File Names (must match exactly):
- `wakeup_alarm.mp3` - For wake up alarms
- `workout_alarm.mp3` - For workout alarms  
- `sleep_alarm.mp3` - For sleep time alarms

## 🎵 Audio Requirements

### Format Guidelines:
- **Format**: MP3
- **Duration**: 3-30 seconds (recommended)
- **Quality**: 44.1kHz, 128-320 kbps
- **Size**: Keep under 1MB per file for optimal performance

### 🔁 For Custom Looping with 2-Second Breaks:
AlarmKit automatically loops alarm sounds. To add a 2-second break between loops:

1. **Edit your MP3 files** to include 2 seconds of silence at the end
2. **Use audio editing software** like Audacity (free) or GarageBand
3. **Steps**:
   - Load your alarm sound
   - Add 2 seconds of silence at the end
   - Export as MP3
   - The loop will naturally have a 2-second break

### 🎵 Recommended Audio Structure:
```
[Your Alarm Sound] → [2 seconds silence] → [Loop repeats]
Example: 10sec sound + 2sec silence = 12sec total file
```

### Adding Files to Xcode:
1. Drag your MP3 files into the Xcode project navigator
2. Make sure "Add to target" is checked for your app target
3. Verify files appear in your app bundle (Build Phases → Copy Bundle Resources)

## 🔧 How It Works

### Custom Sound Logic:
- Uses `AlertConfiguration.AlertSound.named()` API from AlarmKit
- Checks for custom MP3 files in the main bundle
- If found: Creates `AlertConfiguration.AlertSound.named(fileName)`
- If not found: Falls back to `AlertConfiguration.AlertSound.default`
- Each alarm type gets its own unique sound

### Code Implementation:
```swift
let sound = AlertConfiguration.AlertSound.named("wakeup_alarm.mp3")
let alarmConfiguration = AlarmConfiguration(
    countdownDuration: duration,
    schedule: schedule,
    attributes: attributes,
    sound: sound,
    stopIntent: stopIntent,
    secondaryIntent: secondaryIntent
)
```

### Character Integration:
- Wake up alarms play `wakeup_alarm.mp3`
- Workout alarms play `workout_alarm.mp3` (with countdown functionality)
- Sleep alarms play `sleep_alarm.mp3`

### Error Handling:
- Console warnings if audio files are missing
- Graceful fallback to system sounds
- No app crashes from missing audio files

## 🎨 Enhanced Alarm List

### Visual Features:
- Character images displayed in circular frames
- Gradient borders matching alarm type colors
- Character emojis and type emojis
- Enhanced typography with time display

### Layout:
- Character image (60x60 circle)
- Alarm type with emoji
- Character name with emoji  
- Time with clock icon
- Status badge
- Delete button

## 🚀 Testing

1. Add your MP3 files to the project
2. Set up an alarm in Settings → Character Alarms
3. Wait for the alarm to trigger
4. Verify your custom audio plays instead of system sound

---

**Note**: Custom alarm sounds require iOS 26.0+ and AlarmKit framework.