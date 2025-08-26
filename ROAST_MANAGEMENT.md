# Roast Management System

## Overview
All roasts are now centralized in `RoastLibrary.swift` for easy management and expansion. Each character has their own themed roast collections.

## File Structure
```
RoastLibrary.swift
├── Character-specific roast arrays
├── Number-specific roast functions
├── Multi-metric combo roasts
└── Helper functions
```

## Characters & Their Themes

### 🛡️ **Drill Sergeant**
- **Theme**: Military drill instructor style
- **Tone**: Shouty, commanding, uses military terminology
- **Example**: "PATHETIC! I've seen more movement from a statue!"

### 🎙️ **British Narrator**
- **Theme**: David Attenborough-style nature documentary
- **Tone**: Scholarly, observational, treats user like a wildlife specimen
- **Example**: "Observe this magnificent specimen, who has mastered the art of calorie conservation through absolute inactivity."

### 💔 **Your Ex**
- **Theme**: Toxic relationship manipulation
- **Tone**: Passive-aggressive, brings up relationship history
- **Example**: "No workout today? Just like old times - all talk, no action."

### 🔥 **The Savage**
- **Theme**: Brutally honest, no-holds-barred roasting
- **Tone**: Direct, cutting, uses creative insults
- **Example**: "Your fitness level is so low, even your shadow is embarrassed to follow you around."

## Roast Categories

### 1. **No Workout Roasts**
Used when user hasn't exercised:
- `drillSergeantNoWorkoutRoasts[]`
- `britishNarratorNoWorkoutRoasts[]`
- `yourExNoWorkoutRoasts[]`
- `theSavageNoWorkoutRoasts[]`

### 2. **Step Count Roasts**
Used for daily step targets:
- `drillSergeantStepRoasts[]`
- `britishNarratorStepRoasts[]`
- `yourExStepRoasts[]`
- `theSavageStepRoasts[]`

### 3. **Calorie Roasts**
Used for calorie burn performance:
- `drillSergeantCalorieRoasts[]`
- `britishNarratorCalorieRoasts[]`
- `yourExCalorieRoasts[]`
- `theSavageCalorieRoasts[]`

### 4. **Duration Roasts**
Used for workout length:
- `drillSergeantDurationRoasts[]`
- `britishNarratorDurationRoasts[]`
- `yourExDurationRoasts[]`
- `theSavageDurationRoasts[]`

## Adding New Roasts

### Step 1: Choose the Right Array
Navigate to the appropriate character and roast type array in `RoastLibrary.swift`.

### Step 2: Add Your Roast
```swift
static let drillSergeantNoWorkoutRoasts = [
    "EXISTING ROAST!",
    "YOUR NEW ROAST HERE!", // Add your new roast
    "ANOTHER EXISTING ROAST!"
]
```

### Step 3: Follow Character Theme
Make sure your roast matches the character's personality:

**✅ Good Drill Sergeant Roast:**
```swift
"UNACCEPTABLE! Your motivation went AWOL and never reported back!"
```

**❌ Bad Drill Sergeant Roast:**
```swift
"Oh dear, it seems you've missed your workout today." // Too polite!
```

## Number-Specific Roasts

For more personalized roasts, use the number-specific functions:

### `getSpecificStepRoast(stepCount: Int, character: Character)`
- Mentions exact step count in the roast
- Different roast ranges: <500, <2000, <5000, 5000+

### `getSpecificCalorieRoast(calories: Int, character: Character)`
- Mentions exact calorie burn
- Different roast ranges: <50, <150, <300, 300+

### `getSpecificDurationRoast(minutes: Int, character: Character)`
- Mentions exact workout duration
- Different roast ranges: 0, <15, <30, 30+

### `getComboRoast(minutes: Int, calories: Int, heartRate: Int, character: Character)`
- Combines multiple metrics for devastating accuracy
- Perfect for really specific roasting

## Best Practices

### ✅ **DO:**
- Keep character themes consistent
- Use specific numbers when possible
- Make roasts funny, not genuinely hurtful
- Test roasts with different metric ranges
- Add variety to avoid repetition

### ❌ **DON'T:**
- Mix character personalities in the same roast
- Use actually offensive language
- Make roasts too generic
- Forget to test with edge cases (0 steps, etc.)
- Break the fourth wall unless it fits the character

## Examples of Great Roasts

### **Number-Specific (Recommended):**
```swift
"47 steps? Even GPS thinks you're furniture at this point."
"12 minutes of exercise? I've seen longer bathroom breaks."
"89 calories burned? That wouldn't power a calculator."
```

### **Character-Specific Personality:**
```swift
// Drill Sergeant
"SOLDIER! Your fitness level is lower than a snake's belly!"

// British Narrator  
"Here we observe a creature that has evolved beyond the need for movement."

// Your Ex
"Still avoiding commitment, I see. Even to your own health."

// The Savage
"Your workout routine is more mythical than unicorns riding dragons."
```

## Testing Your Roasts

1. Add roasts to the appropriate array
2. Build and run the app
3. Test with different workout scenarios
4. Make sure the roast fits the character's voice
5. Check for typos and formatting

## Character Voice Guidelines

### **Drill Sergeant Voice:**
- ALL CAPS for emphasis
- Use military terms: "SOLDIER!", "RECRUIT!", "MAGGOT!"
- Commands and orders
- Comparison to military standards

### **British Narrator Voice:**
- Scholarly vocabulary
- "Observe...", "Here we witness...", "Fascinating!"
- Treat user like a wildlife specimen
- Scientific comparisons

### **Your Ex Voice:**
- Passive-aggressive tone
- Reference relationship history
- "Just like old times...", "Some things never change..."
- Emotional manipulation tactics

### **The Savage Voice:**
- Direct and brutal
- Creative insults and comparisons
- No sugar-coating
- Pop culture references welcome

Remember: The goal is to motivate through humor and light shame, not to genuinely hurt feelings!