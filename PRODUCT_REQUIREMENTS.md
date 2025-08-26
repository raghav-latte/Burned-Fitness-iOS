# Burned: Product Requirements Document

## Executive Summary

**Burned** is a motivational fitness app that uses AI-powered roasting and shame-based motivation to encourage users to maintain their workout routines. By analyzing health data and delivering brutally honest, humorous critiques via voice, Burned transforms fitness tracking into an entertaining and engaging experience.

## Product Vision

"To revolutionize fitness motivation by replacing generic encouragement with personalized, brutally honest AI roasts that shame users into achieving their fitness goals."

## Core Value Proposition

- **Unique Motivation Method**: Uses humor and light shame instead of traditional positive reinforcement
- **Personalized AI Roasts**: Contextual roasts based on actual fitness performance data
- **Voice-First Experience**: Immersive audio experience with distinct character personalities
- **Real-Time Health Integration**: Seamless HealthKit integration for automatic data collection

## Target Market

### Primary Users
- **Millennials/Gen-Z (22-35)**: Tech-savvy users who appreciate humor and sarcasm
- **Fitness Enthusiasts**: Regular gym-goers who want accountability and motivation
- **Inconsistent Exercisers**: People who struggle with workout consistency and need external motivation

### Market Size
- US fitness app market: $4.4B (2023)
- Projected growth rate: 14.7% CAGR through 2030
- Target addressable market: 15-20M users in English-speaking markets

## Product Features

### Core Features

#### 1. AI-Powered Roast Generation
- **Dynamic Content Creation**: Contextual roasts based on workout performance metrics
- **Multi-Factor Analysis**: Considers steps, calories, duration, heart rate, and consistency
- **Character-Specific Personalities**: Different roasting styles per voice character
- **Performance-Based Escalation**: Roast intensity scales with poor performance

#### 2. Voice Character System
- **Multiple Personalities**: 
  - Drill Sergeant (tough love military style)
  - British Narrator (David Attenborough-esque documentary style)
  - Your Ex (toxic relationship manipulation)
- **ElevenLabs Integration**: Premium AI voice synthesis for realistic character voices
- **Customizable Voice Settings**: Stability, similarity, style, and speaker boost parameters

#### 3. Health Data Integration
- **HealthKit Connectivity**: Automatic sync with Apple Health
- **Comprehensive Metrics**:
  - Daily step count
  - Workout duration and intensity
  - Heart rate monitoring
  - Calorie burn tracking
  - Sleep analysis
- **Real-Time Updates**: Live data synchronization for immediate feedback

#### 4. Smart Notification System
- **Dual Notification Strategy**:
  - OneSignal for push notifications
  - Local notifications as backup
- **Intelligent Timing**: Context-aware notification scheduling
- **Background Processing**: Workout detection and analysis

### User Experience Features

#### 1. Tab-Based Navigation
- **Home Tab**: Main dashboard with key stats and primary roast button
- **Explore Tab**: Character selection and fitness challenges
- **Summary Tab**: Daily performance overview and sharing capabilities
- **Settings Tab**: Personalization and configuration options

#### 2. Interactive Stat Blocks
- **Tap-to-Roast**: Individual metric roasting for specific performance areas
- **Visual Feedback**: Color-coded performance indicators
- **Real-Time Updates**: Live metric refreshing

#### 3. Character Selection Interface
- **Visual Character Cards**: Emoji-based character representation
- **Voice Previews**: Sample roast playback for character evaluation
- **Easy Switching**: Seamless character selection process

### Advanced Features

#### 1. Workout History Analysis
- **30-Day Performance Tracking**: Historical workout data visualization
- **Individual Workout Roasting**: Specific roasts for past workout sessions
- **Performance Trend Analysis**: Pattern recognition for consistent underperformance

#### 2. Customization Options
- **Roast Intensity Slider**: 5-level intensity scale (gentle to savage)
- **Notification Frequency**: 1-12 hour reminder intervals
- **Auto-Sharing**: Optional social media integration

#### 3. Challenge System
- **Pre-Defined Challenges**: "Survive 30 days without excuses", "Beat your laziest week record"
- **Gamification Elements**: Progress tracking and achievement unlocks

## Technical Architecture

### Frontend (iOS - SwiftUI)
- **SwiftUI Framework**: Modern declarative UI framework
- **MVVM Architecture**: Clean separation of concerns
- **Combine Framework**: Reactive programming for data binding
- **Environment Objects**: Shared state management

### Backend Integrations
- **ElevenLabs API**: Text-to-speech voice synthesis
- **Apple HealthKit**: Health data retrieval and monitoring
- **OneSignal**: Push notification delivery service
- **Background Tasks**: iOS background app refresh for workout detection

### Data Management
- **Local Core Data**: User preferences and cached data
- **HealthKit Store**: Primary health data source
- **Cloud Sync**: User settings and character preferences

### Security & Privacy
- **HealthKit Permissions**: Granular health data access controls
- **API Key Management**: Secure storage of third-party service credentials
- **Local Data Processing**: Minimize cloud data transmission

## User Personas

### 1. "Accountable Alex" - The Fitness Enthusiast
- **Age**: 28
- **Profile**: Regular gym-goer who tracks all workouts
- **Pain Point**: Needs external motivation to push harder during workouts
- **Use Case**: Uses Burned for post-workout performance analysis and daily motivation
- **Preferred Character**: Drill Sergeant for maximum intensity

### 2. "Inconsistent Ivy" - The Fitness Struggler  
- **Age**: 25
- **Profile**: Wants to be fit but struggles with consistency
- **Pain Point**: Lacks accountability and external motivation
- **Use Case**: Needs daily reminders and shame-based motivation to maintain routine
- **Preferred Character**: Your Ex for emotional manipulation tactics

### 3. "Data-Driven Dan" - The Quantified Self Enthusiast
- **Age**: 32
- **Profile**: Tracks everything and loves detailed analytics
- **Pain Point**: Generic fitness apps lack personality and engagement
- **Use Case**: Enjoys detailed performance breakdowns with entertaining commentary
- **Preferred Character**: British Narrator for intellectual humor

## User Journey

### Onboarding Flow
1. **App Launch**: Character selection overlay
2. **Health Permissions**: HealthKit authorization request
3. **Notification Setup**: Push notification permissions
4. **Initial Setup**: Intensity preferences and reminder frequency
5. **First Roast**: Welcome roast from selected character

### Daily Usage Flow
1. **Morning Check-in**: App launch triggers health data sync
2. **Performance Review**: Real-time stat updates on home screen
3. **Interactive Roasting**: Tap individual stats for specific roasts
4. **Workout Detection**: Automatic detection and post-workout roasting
5. **Evening Summary**: Daily performance recap and sharing options

### Weekly Engagement
1. **Weekly Summary**: Performance trends and consistency analysis
2. **Challenge Updates**: Progress on selected fitness challenges
3. **Character Switching**: Experimenting with different roasting personalities

## Monetization Strategy

### Freemium Model
- **Free Tier**: 
  - Basic roast generation (limited daily roasts)
  - Single character access
  - Standard notification frequency
- **Premium Tier** ($4.99/month or $29.99/year):
  - Unlimited roasts
  - All character voices
  - Advanced customization options
  - Priority support

### Revenue Streams
1. **Subscription Revenue**: Primary income from premium subscriptions
2. **In-App Purchases**: Additional character packs or voice customizations
3. **Partnership Opportunities**: Fitness brand integrations and sponsored challenges

### User Acquisition
- **Organic Growth**: Social sharing of entertaining roasts
- **Influencer Marketing**: Fitness personality partnerships
- **App Store Optimization**: Keyword optimization for fitness motivation apps

## Success Metrics

### Engagement Metrics
- **Daily Active Users (DAU)**: Target 60% of monthly users
- **Session Length**: Average 3-5 minutes per session
- **Roast Frequency**: 5+ roasts per user per day
- **Voice Playback Rate**: 80% of roasts played to completion

### Retention Metrics
- **Day 1 Retention**: 75% of new users return next day
- **Week 1 Retention**: 45% of users remain active after 7 days
- **Month 1 Retention**: 25% of users remain active after 30 days

### Business Metrics
- **Premium Conversion Rate**: 15% of free users upgrade within 30 days
- **Monthly Recurring Revenue (MRR)**: Target $50K within 12 months
- **Customer Lifetime Value (LTV)**: $25 average per user
- **Cost Per Acquisition (CPA)**: Under $10 per user

### Health Impact Metrics
- **Workout Frequency**: 20% increase in user workout frequency
- **Step Count Improvement**: 15% increase in average daily steps
- **Consistency Score**: 30% improvement in workout regularity

## Risk Analysis

### Technical Risks
- **ElevenLabs API Dependency**: Voice synthesis service availability and cost scaling
- **HealthKit Limitations**: iOS-only ecosystem limits Android expansion
- **Background Processing**: iOS restrictions on background app refresh

### Market Risks
- **Niche Appeal**: Humor-based motivation may not appeal to all users
- **Competitive Landscape**: Established fitness apps with larger user bases
- **Content Sensitivity**: Roast content may be considered offensive by some users

### Mitigation Strategies
- **API Redundancy**: Backup voice synthesis solutions
- **Cross-Platform Development**: Future Android version with Google Fit integration
- **Content Moderation**: Intensity controls and opt-out mechanisms

## Development Roadmap

### Phase 1 (Months 1-3): MVP Launch
- Core roasting functionality
- HealthKit integration
- Basic character system
- iOS App Store release

### Phase 2 (Months 4-6): Enhancement
- Additional voice characters
- Advanced customization options
- Social sharing features
- Premium subscription launch

### Phase 3 (Months 7-12): Expansion
- Android version development
- Fitness tracking device integrations
- Community features and challenges
- International market expansion

## Competitive Analysis

### Direct Competitors
- **MyFitnessPal**: Traditional positive reinforcement approach
- **Strava**: Social fitness tracking with community motivation
- **Nike Training Club**: Professional trainer guidance

### Competitive Advantages
- **Unique Motivation Approach**: Only app using AI-powered roasting for fitness motivation
- **Voice-First Experience**: Immersive audio personality system
- **Real-Time Contextual Feedback**: Instant performance-based roasting
- **Entertainment Value**: High shareability and viral potential

### Differentiation Strategy
- **Humor as Motivation**: Transform fitness tracking into entertainment
- **Personality-Driven Experience**: Strong character development and voice acting
- **Anti-Motivational Motivation**: Reverse psychology approach to fitness encouragement

## Conclusion

Burned represents a revolutionary approach to fitness motivation, combining cutting-edge AI voice synthesis with brutally honest performance analysis to create an engaging and effective fitness companion. By targeting users who respond to humor and light shame as motivation techniques, Burned fills a unique niche in the crowded fitness app market while providing genuine value through personalized, contextual feedback based on real health data.

The app's success will depend on its ability to balance entertainment value with genuine fitness motivation, ensuring that users find the experience both enjoyable and effective in improving their health outcomes. With proper execution and user acquisition strategies, Burned has the potential to become a category-defining application in the fitness technology space.