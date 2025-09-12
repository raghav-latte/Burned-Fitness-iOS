import SwiftUI

struct FlyingSparkView: View {
    @State private var sparks: [Spark] = []
    @State private var animationTimer: Timer?
    
    private let sparkCount = 15
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparks) { spark in
                    SparkParticle(spark: spark, containerSize: geometry.size)
                }
            }
            .onAppear {
                generateSparks(containerSize: geometry.size)
                startAnimation(containerSize: geometry.size)
            }
            .onDisappear {
                animationTimer?.invalidate()
            }
        }
    }
    
    private func generateSparks(containerSize: CGSize) {
        sparks = (0..<sparkCount).map { _ in
            Spark(
                x: Double.random(in: 0...Double(containerSize.width)),
                y: Double.random(in: 0...Double(containerSize.height)),
                size: Double.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8),
                color: [Color.orange, Color.red, Color.yellow].randomElement()!,
                velocityX: Double.random(in: -30...30),
                velocityY: Double.random(in: -50...50),
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func startAnimation(containerSize: CGSize) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateSparks(containerSize: containerSize)
        }
    }
    
    private func updateSparks(containerSize: CGSize) {
        for i in sparks.indices {
            // Update position
            sparks[i].x += sparks[i].velocityX * 0.1
            sparks[i].y += sparks[i].velocityY * 0.1
            
            // Update rotation
            sparks[i].rotation += Double.random(in: 1...5)
            
            // Gravity effect
            sparks[i].velocityY += 2
            
            // Random flutter
            sparks[i].velocityX += Double.random(in: -2...2)
            
            // Fade out over time
            sparks[i].opacity -= 0.005
            
            // Reset spark if it goes off screen or fades out
            if sparks[i].y > Double(containerSize.height) + 50 || 
               sparks[i].x < -50 || 
               sparks[i].x > Double(containerSize.width) + 50 || 
               sparks[i].opacity <= 0 {
                sparks[i] = Spark(
                    x: Double.random(in: 0...Double(containerSize.width)),
                    y: -50,
                    size: Double.random(in: 2...6),
                    opacity: Double.random(in: 0.3...0.8),
                    color: [Color.orange, Color.red, Color.yellow].randomElement()!,
                    velocityX: Double.random(in: -30...30),
                    velocityY: Double.random(in: -20...10),
                    rotation: Double.random(in: 0...360)
                )
            }
        }
    }
}

struct Spark: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var size: Double
    var opacity: Double
    var color: Color
    var velocityX: Double
    var velocityY: Double
    var rotation: Double
}

struct SparkParticle: View {
    let spark: Spark
    let containerSize: CGSize
    
    var body: some View {
        ZStack {
            // Main spark circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            spark.color.opacity(spark.opacity),
                            spark.color.opacity(spark.opacity * 0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: spark.size
                    )
                )
                .frame(width: spark.size, height: spark.size)
            
            // Glow effect
            Circle()
                .fill(spark.color.opacity(spark.opacity * 0.2))
                .frame(width: spark.size * 2, height: spark.size * 2)
                .blur(radius: spark.size * 0.5)
            
            // Inner bright core
            Circle()
                .fill(Color.white.opacity(spark.opacity * 0.6))
                .frame(width: spark.size * 0.3, height: spark.size * 0.3)
        }
        .position(x: CGFloat(spark.x), y: CGFloat(spark.y))
        .rotationEffect(.degrees(spark.rotation))
        .animation(.linear(duration: 0.1), value: spark.x)
        .animation(.linear(duration: 0.1), value: spark.y)
        .blendMode(.screen) // Makes sparks blend nicely with background
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FlyingSparkView()
    }
}