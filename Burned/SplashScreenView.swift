//
//  SplashScreenView.swift
//  Burned
//
//  Created by Raghav Sethi on 30/08/25.
//

import SwiftUI
import AVKit

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @State private var player: AVPlayer?
    @State private var textScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background Video
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .disabled(true)
            }
            
            // Dark overlay to make content readable
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Content - Perfectly Centered
            GeometryReader { geometry in
                    Text("Burned!")
                        .font(.custom("PilatWide-Heavy", size: 48))
                        .foregroundColor(.white)
                        .scaleEffect(textScale)
                        .opacity(textOpacity)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                
            }
        }
        .onAppear {
            setupVideoPlayer()
            animateText()
            
            // Debug: Print available fonts
            FontHelper.printCustomFonts()
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupVideoPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "onboarding", withExtension: "mov") else {
            print("⚠️ Could not find onboarding.mov in bundle")
            return
        }
        
        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        player?.play()
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
    
    private func animateText() {
        // Initial delay before text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 1.0
            }
            
            // Scale animation with bounce effect
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
                textScale = 1.2
            }
            
            // Additional grow effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    textScale = 1.5
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(showSplash: .constant(true))
    }
}
