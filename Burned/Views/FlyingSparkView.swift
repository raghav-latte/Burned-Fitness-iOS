import SwiftUI

struct FlyingSparkView: View {
    @State private var sparks: [SparkParticle] = []
    @State private var animationTimer: Timer?
    
    let maxSparks = 5000
    let sparkLifetime: TimeInterval = 6.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                ForEach(sparks, id: \.id) { spark in
                    SparkView(spark: spark)
                }
                
                // Burned text overlay
                Text("Burned!")
                    .font(.custom("PilatWide-Heavy", size: 48))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
            }
            .onAppear {
                startSparkAnimation(in: geometry.size)
            }
            .onDisappear {
                stopSparkAnimation()
            }
        }
    }
    
    private func startSparkAnimation(in size: CGSize) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            createNewSpark(in: size)
            cleanupOldSparks()
        }
    }
    
    private func stopSparkAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func createNewSpark(in size: CGSize) {
        if sparks.count < maxSparks {
            // Generate random direction with weighted probability (less from sides)
            let random = Double.random(in: 0...1)
            let edge: Int
            if random < 0.4 { // 40% from bottom
                edge = 0
            } else if random < 0.8 { // 40% from top
                edge = 1
            } else if random < 0.9 { // 10% from left
                edge = 2
            } else { // 10% from right
                edge = 3
            }
            let (startPos, endPos) = generateSimpleRandomPath(in: size, fromEdge: edge)
            
            let newSpark = SparkParticle(
                id: UUID(),
                startPosition: startPos,
                endPosition: endPos,
                size: CGFloat.random(in: 3...20),
                opacity: Double.random(in: 0.6...1.0),
                creationTime: Date(),
                color: generateRandomOrange(),
                hasGlow: Double.random(in: 0...1) < 0.2
            )
            sparks.append(newSpark)
        }
    }
    
    private func cleanupOldSparks() {
        let now = Date()
        sparks.removeAll { spark in
            now.timeIntervalSince(spark.creationTime) > sparkLifetime
        }
    }
}

struct SparkParticle {
    let id: UUID
    let startPosition: CGPoint
    let endPosition: CGPoint
    let size: CGFloat
    let opacity: Double
    let creationTime: Date
    let color: Color
    let hasGlow: Bool
}

struct SparkView: View {
    let spark: SparkParticle
    @State private var position: CGPoint
    @State private var currentOpacity: Double
    @State private var scale: CGFloat = 0
    @State private var glowIntensity: Double = 1.0
    
    init(spark: SparkParticle) {
        self.spark = spark
        self._position = State(initialValue: spark.startPosition)
        self._currentOpacity = State(initialValue: spark.opacity)
    }
    
    var body: some View {
        ZStack {
            // Main spark
            Circle()
                .fill(
                    RadialGradient(
                        colors: [spark.color, spark.color.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: spark.size / 2
                    )
                )
                .frame(width: spark.size, height: spark.size)
                .blur(radius: spark.size > 10 ? spark.size * 0.1 : 0)
            
            // Variable glow effect (only for 20% of sparks)
            if spark.hasGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [spark.color.opacity(0.4 * glowIntensity), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: spark.size * 1.5
                        )
                    )
                    .frame(width: spark.size * 3, height: spark.size * 3)
                    .blur(radius: spark.size * 0.15)
                    .opacity(glowIntensity)
            }
        }
        .opacity(currentOpacity)
        .scaleEffect(scale)
        .position(position)
        .onAppear {
                withAnimation(.linear(duration: 6.0)) {
                    position = spark.endPosition
                }
                
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 1.0
                }
                
                // Glow pulsing animation: high -> low -> high -> fade out
                withAnimation(.easeInOut(duration: 2.0)) {
                    glowIntensity = 0.6
                }
                withAnimation(.easeInOut(duration: 2.0).delay(2.0)) {
                    glowIntensity = 1.0
                }
                withAnimation(.easeIn(duration: 2.0).delay(4.0)) {
                    glowIntensity = 0.0
                    currentOpacity = 0
                    scale = 0.2
                }
            }
    }
}

// Enhanced version with more dynamic movement
struct EnhancedFlyingSparkView: View {
    @State private var sparks: [EnhancedSparkParticle] = []
    @State private var animationTimer: Timer?
    
    let maxSparks = 25
    let sparkLifetime: TimeInterval = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparks, id: \.id) { spark in
                    EnhancedSparkView(spark: spark)
                }
            }
            .onAppear {
                startSparkAnimation(in: geometry.size)
            }
            .onDisappear {
                stopSparkAnimation()
            }
        }
    }
    
    private func startSparkAnimation(in size: CGSize) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            createNewSpark(in: size)
            cleanupOldSparks()
        }
    }
    
    private func stopSparkAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func createNewSpark(in size: CGSize) {
        if sparks.count < maxSparks {
            // Random starting position with weighted probability (less from sides)
            let random = Double.random(in: 0...1)
            let edge: Int
            if random < 0.4 { // 40% from bottom
                edge = 0
            } else if random < 0.8 { // 40% from top
                edge = 1
            } else if random < 0.9 { // 10% from left
                edge = 2
            } else { // 10% from right
                edge = 3
            }
            let (startPos, endPos, control1, control2) = generateRandomPath(in: size, fromEdge: edge)
            
            let newSpark = EnhancedSparkParticle(
                id: UUID(),
                startPosition: startPos,
                controlPoint1: control1,
                controlPoint2: control2,
                endPosition: endPos,
                size: CGFloat.random(in: 6...20),
                opacity: Double.random(in: 0.4...1.0),
                creationTime: Date(),
                color: generateRandomOrange(),
                rotationSpeed: Double.random(in: 1...3)
            )
            sparks.append(newSpark)
        }
    }
    
    private func cleanupOldSparks() {
        let now = Date()
        sparks.removeAll { spark in
            now.timeIntervalSince(spark.creationTime) > sparkLifetime
        }
    }
}

struct EnhancedSparkParticle {
    let id: UUID
    let startPosition: CGPoint
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
    let endPosition: CGPoint
    let size: CGFloat
    let opacity: Double
    let creationTime: Date
    let color: Color
    let rotationSpeed: Double
}

struct EnhancedSparkView: View {
    let spark: EnhancedSparkParticle
    @State private var animationProgress: CGFloat = 0
    @State private var currentOpacity: Double
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    
    init(spark: EnhancedSparkParticle) {
        self.spark = spark
        self._currentOpacity = State(initialValue: spark.opacity)
    }
    
    var body: some View {
        Group {
            // Main spark
            Circle()
                .fill(
                    RadialGradient(
                        colors: [spark.color, spark.color.opacity(0.5), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: spark.size / 2
                    )
                )
                .frame(width: spark.size, height: spark.size)
                //.blur(radius: spark.size > 5 ? spark.size * 0.12 : 0)
            
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [spark.color.opacity(0.4), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: spark.size
                    )
                )
                .frame(width: spark.size * 1.5, height: spark.size * 1.5)
                //.blur(radius: spark.size > 5 ? spark.size * 0.15 : 0)
            
            // Trailing effect
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [spark.color.opacity(0.6), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: spark.size * 1, height: spark.size * 0.5)
                .rotationEffect(.degrees(rotation + getTrailRotation()))
        }
        .opacity(currentOpacity)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .position(getCurrentPosition())
        .onAppear {
            withAnimation(.linear(duration: 4.0)) {
                animationProgress = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.3)) {
                scale = 1.0
            }
            
            withAnimation(.easeIn(duration: 3.0).delay(1.0)) {
                currentOpacity = 0
                scale = 0.1
            }
            
            withAnimation(.linear(duration: 4.0)) {
                rotation = 360 * spark.rotationSpeed
            }
        }
    }
    
    private func getCurrentPosition() -> CGPoint {
        // Bezier curve interpolation for smooth curved flight path
        let t = animationProgress
        let oneMinusT = 1 - t
        
        return CGPoint(
            x: pow(oneMinusT, 3) * spark.startPosition.x +
               3 * pow(oneMinusT, 2) * t * spark.controlPoint1.x +
               3 * oneMinusT * pow(t, 2) * spark.controlPoint2.x +
               pow(t, 3) * spark.endPosition.x,
            y: pow(oneMinusT, 3) * spark.startPosition.y +
               3 * pow(oneMinusT, 2) * t * spark.controlPoint1.y +
               3 * oneMinusT * pow(t, 2) * spark.controlPoint2.y +
               pow(t, 3) * spark.endPosition.y
        )
    }
    
    private func getTrailRotation() -> Double {
        // Calculate direction based on current movement
        let currentPos = getCurrentPosition()
        let nextT = min(animationProgress + 0.01, 1.0)
        let oneMinusNextT = 1 - nextT
        
        let nextPos = CGPoint(
            x: pow(oneMinusNextT, 3) * spark.startPosition.x +
               3 * pow(oneMinusNextT, 2) * nextT * spark.controlPoint1.x +
               3 * oneMinusNextT * pow(nextT, 2) * spark.controlPoint2.x +
               pow(nextT, 3) * spark.endPosition.x,
            y: pow(oneMinusNextT, 3) * spark.startPosition.y +
               3 * pow(oneMinusNextT, 2) * nextT * spark.controlPoint1.y +
               3 * oneMinusNextT * pow(nextT, 2) * spark.controlPoint2.y +
               pow(nextT, 3) * spark.endPosition.y
        )
        
        let dx = nextPos.x - currentPos.x
        let dy = nextPos.y - currentPos.y
        
        return atan2(dy, dx) * 180 / .pi
    }
}

// Usage in your Burned app - can be added as overlay to buttons or as background effect
struct SparkEffectModifier: ViewModifier {
    @State private var showSparks = false
    let triggerAnimation: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if showSparks {
                        EnhancedFlyingSparkView()
                            .allowsHitTesting(false)
                    }
                }
            )
            .onChange(of: triggerAnimation) { _, newValue in
                if newValue {
                    showSparks = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        showSparks = false
                    }
                }
            }
    }
}

// Helper function for simple random paths
private func generateSimpleRandomPath(in size: CGSize, fromEdge edge: Int) -> (start: CGPoint, end: CGPoint) {
    let margin: CGFloat = 20
    
    switch edge {
    case 0: // Bottom to top
        return (
            start: CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + margin),
            end: CGPoint(x: CGFloat.random(in: 0...size.width), y: -margin)
        )
    case 1: // Top to bottom
        return (
            start: CGPoint(x: CGFloat.random(in: 0...size.width), y: -margin),
            end: CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + margin)
        )
    case 2: // Left to right
        return (
            start: CGPoint(x: -margin, y: CGFloat.random(in: 0...size.height)),
            end: CGPoint(x: size.width + margin, y: CGFloat.random(in: 0...size.height))
        )
    case 3: // Right to left
        return (
            start: CGPoint(x: size.width + margin, y: CGFloat.random(in: 0...size.height)),
            end: CGPoint(x: -margin, y: CGFloat.random(in: 0...size.height))
        )
    default:
        return (
            start: CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + margin),
            end: CGPoint(x: CGFloat.random(in: 0...size.width), y: -margin)
        )
    }
}

// Helper functions for random orange colors and paths
private func generateRandomOrange() -> Color {
    let orangeShades: [Color] = [
        Color(red: 1.0, green: 0.3, blue: 0.0),    // Red orange
        Color(red: 0.9, green: 0.2, blue: 0.0),    // Deep red orange
        Color(red: 1.0, green: 0.4, blue: 0.0),    // Dark orange
        Color(red: 0.8, green: 0.3, blue: 0.0),    // Burnt orange
        Color(red: 1.0, green: 0.25, blue: 0.0),   // Crimson orange
        Color(red: 0.9, green: 0.35, blue: 0.1),   // Rust orange
        Color(red: 1.0, green: 0.45, blue: 0.1),   // Fire orange
        Color(red: 0.85, green: 0.25, blue: 0.0),  // Dark rust
        Color(red: 1.0, green: 0.35, blue: 0.05),  // Blood orange
        Color(red: 0.9, green: 0.4, blue: 0.1)     // Copper orange
    ]
    return orangeShades.randomElement() ?? .orange
}

private func generateRandomPath(in size: CGSize, fromEdge edge: Int) -> (start: CGPoint, end: CGPoint, control1: CGPoint, control2: CGPoint) {
    let margin: CGFloat = 20
    
    switch edge {
    case 0: // Bottom edge
        let startX = CGFloat.random(in: 0...size.width)
        let endX = CGFloat.random(in: 0...size.width)
        return (
            start: CGPoint(x: startX, y: size.height + margin),
            end: CGPoint(x: endX, y: -margin),
            control1: CGPoint(x: startX + CGFloat.random(in: -100...100), y: size.height * 0.7),
            control2: CGPoint(x: endX + CGFloat.random(in: -100...100), y: size.height * 0.3)
        )
    case 1: // Top edge
        let startX = CGFloat.random(in: 0...size.width)
        let endX = CGFloat.random(in: 0...size.width)
        return (
            start: CGPoint(x: startX, y: -margin),
            end: CGPoint(x: endX, y: size.height + margin),
            control1: CGPoint(x: startX + CGFloat.random(in: -100...100), y: size.height * 0.3),
            control2: CGPoint(x: endX + CGFloat.random(in: -100...100), y: size.height * 0.7)
        )
    case 2: // Left edge
        let startY = CGFloat.random(in: 0...size.height)
        let endY = CGFloat.random(in: 0...size.height)
        return (
            start: CGPoint(x: -margin, y: startY),
            end: CGPoint(x: size.width + margin, y: endY),
            control1: CGPoint(x: size.width * 0.3, y: startY + CGFloat.random(in: -100...100)),
            control2: CGPoint(x: size.width * 0.7, y: endY + CGFloat.random(in: -100...100))
        )
    case 3: // Right edge
        let startY = CGFloat.random(in: 0...size.height)
        let endY = CGFloat.random(in: 0...size.height)
        return (
            start: CGPoint(x: size.width + margin, y: startY),
            end: CGPoint(x: -margin, y: endY),
            control1: CGPoint(x: size.width * 0.7, y: startY + CGFloat.random(in: -100...100)),
            control2: CGPoint(x: size.width * 0.3, y: endY + CGFloat.random(in: -100...100))
        )
    default:
        // Fallback to bottom edge
        let startX = CGFloat.random(in: 0...size.width)
        let endX = CGFloat.random(in: 0...size.width)
        return (
            start: CGPoint(x: startX, y: size.height + margin),
            end: CGPoint(x: endX, y: -margin),
            control1: CGPoint(x: startX + CGFloat.random(in: -100...100), y: size.height * 0.7),
            control2: CGPoint(x: endX + CGFloat.random(in: -100...100), y: size.height * 0.3)
        )
    }
}

extension View {
    func flyingSparks(trigger: Bool) -> some View {
        modifier(SparkEffectModifier(triggerAnimation: trigger))
    }
}
