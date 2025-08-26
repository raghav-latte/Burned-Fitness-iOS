# Roast Caching System - Token Optimization

## Overview
The Burned app now includes a comprehensive caching system to minimize ElevenLabs API usage while maintaining the dynamic roasting experience.

## 🎯 **Problem Solved**
- **Expensive API calls**: ElevenLabs charges per character (~$0.30 per 1K characters)
- **Repeated roasts**: Users often get similar workout patterns
- **Network dependency**: Offline capability for cached content
- **Performance**: Faster roast delivery for cached content

## 🏗️ **Two-Tier Caching Architecture**

### **Tier 1: Text Roast Cache (`RoastCache.swift`)**
Pre-written roasts for common scenarios, stored in code:

```swift
// Example: Low step count scenarios
"steps_under_500": [
    "Step count so low I thought your phone was charging all day.",
    "You've taken more screenshots than steps today.",
    "Even statues move more than you do."
]
```

**Scenarios Covered:**
- No workout (0 mins, 0 calories)
- Low steps (<500, <2000)
- Low calories (<100)
- Short workouts (<15 mins)
- Character-specific performance levels

### **Tier 2: Audio Cache (`AudioCacheManager`)**
Stores generated TTS audio files locally:

- **Location**: `Documents/RoastCache/`
- **Format**: `.m4a` files
- **Size Limit**: 50MB (auto-cleanup)
- **Naming**: Hash of text + character combination

## 🔄 **Cache Flow Process**

```
User requests roast
       ↓
1. Check RoastCache for pre-written text
   ├─ Found → Use cached text
   └─ Not found → Generate from RoastLibrary
       ↓
2. Check AudioCache for TTS audio  
   ├─ Found → Play immediately (FAST!)
   └─ Not found → Call ElevenLabs API
       ↓
3. Cache new audio for future use
```

## 💰 **Token Savings**

### **Before Caching:**
- Every roast = API call
- ~50 chars per roast = ~$0.015 per roast
- 100 roasts/day = ~$1.50/day per user

### **After Caching:**
- Common scenarios: 0 API calls (80%+ of usage)
- New scenarios: 1 API call, then cached forever
- Estimated savings: **85-95% reduction in API costs**

## 📊 **Cache Performance Monitoring**

The system tracks:
- **Total Requests**: Number of roast requests
- **Cache Hits**: Requests served from cache
- **Hit Rate**: Percentage of cached responses
- **Cache Size**: Total storage used

Access via: `ElevenLabsManager.shared.getCacheStats()`

## 🎭 **Character-Specific Caching**

Each character has optimized cache entries:

### **Drill Sergeant**
```swift
"low_performance": [
    "PATHETIC! I've seen more intensity in a chess match!",
    "SOLDIER! Your fitness level is lower than a snake's belly!"
]
```

### **British Narrator**
```swift
"low_performance": [
    "Here we observe a creature that has mastered calorie conservation.",
    "Fascinating! This specimen has achieved furniture-level mobility."
]
```

### **Your Ex**
```swift
"low_performance": [
    "Just like old times - all talk, no action.",
    "Still choosing the couch over self-improvement. Classic you."
]
```

### **The Savage**
```swift
"low_performance": [
    "Your fitness level is so low, even your shadow is embarrassed.",
    "You've achieved legendary status in the Hall of Disappointment."
]
```

## 🚀 **Pre-Generation System**

For maximum optimization, the app can pre-generate audio for common scenarios:

```swift
// Pre-generate roasts for all characters
ElevenLabsManager.shared.preGenerateCommonRoasts(for: character) { completed, total in
    print("Pre-generated \(completed)/\(total) roasts")
}
```

**Suggested Pre-Generation Scenarios:**
- No workout (0 steps, 0 calories, 0 mins)
- Light workout (2000 steps, 50 cals, 5 mins)
- Short workout (3000 steps, 100 cals, 10 mins)
- Decent workout (4000 steps, 150 cals, 15 mins)
- Good workout (8000 steps, 200 cals, 30 mins)

## 🛠️ **Cache Management**

### **Automatic Management:**
- **Size Monitoring**: Automatically cleans up when exceeding 50MB
- **LRU Eviction**: Removes oldest files first
- **Corruption Handling**: Graceful fallback to API if cached file is corrupted

### **Manual Management:**
```swift
// Clear all cached audio
ElevenLabsManager.shared.clearCache()

// Get cache statistics
let stats = ElevenLabsManager.shared.getCacheStats()
print("Cache size: \(stats.size), Hit rate: \(stats.hitRate)")
```

## 📈 **Usage Optimization Strategies**

### **1. Smart Pre-Loading**
- Pre-generate roasts for user's selected character on app launch
- Focus on their typical workout patterns
- Background generation during idle time

### **2. Contextual Caching**
- Prioritize caching for user's common performance ranges
- Cache seasonal patterns (holidays, New Year, summer)
- Cache based on user behavior analytics

### **3. Network-Aware Caching**
- Aggressive caching on WiFi
- Conservative API usage on cellular
- Offline-first approach when possible

## 🔧 **Integration Points**

### **RoastGenerator Updates:**
All roast generation now follows cache-first pattern:
```swift
// Try cached roast first
if let cachedRoast = RoastCache.getCachedRoast(for: character, ...) {
    return cachedRoast
}
// Fall back to dynamic generation
return RoastLibrary.getSpecificRoast(...)
```

### **ElevenLabsManager Updates:**
Audio requests now check cache first:
```swift
// Check audio cache before API call
if let cachedAudio = audioCache.getCachedAudio(for: text, character: character) {
    playAudio(data: cachedAudio) // Instant playback!
    return
}
// Generate and cache new audio
generateAndCacheAudio(for: text)
```

## 📝 **Best Practices**

### **For Adding New Roasts:**
1. Add to `RoastCache` for common scenarios
2. Use specific metrics in roasts for better caching
3. Consider character personality consistency

### **For Performance:**
1. Pre-generate during app idle time
2. Monitor cache hit rates
3. Adjust cache scenarios based on user patterns

### **For Storage:**
1. Keep cache under 50MB limit
2. Periodically clean up old unused files
3. Provide user control over cache management

## 🎉 **Expected Results**

With this caching system:
- **95%+ faster** roast delivery for cached content
- **85-95% reduction** in API costs
- **Better offline experience** with cached roasts
- **Improved user experience** with instant roast playback
- **Scalable system** that gets more efficient over time

The more the app is used, the smarter the caching becomes, creating a system that reduces costs while improving performance! 🚀