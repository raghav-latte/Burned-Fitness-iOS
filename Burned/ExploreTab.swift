//
//  ExploreTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI
import RevenueCat
import RevenueCatUI

struct ExploreTab: View {
    @State private var selectedCharacterIndex = 0
    @ObservedObject private var speechManager = ElevenLabsManager.shared
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @State private var hasPremium = false
    @State private var showPaywall = false
    
    private let characters = Character.allCharacters
    
    private let challenges = [
        "Survive 30 days without excuses",
        "Beat your laziest week record",
        "Burn more calories than you make excuses",
        "Take more steps than selfies"
    ]
    
    var body: some View {
        return ZStack {
            // Black background
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                // Character images with circular gradient halo
                TabView(selection: $selectedCharacterIndex) {
                    ForEach(0..<characters.count, id: \.self) { index in
                        VStack {
                            Spacer().frame(height: 60)
                            
                            ZStack {
                                // Circular gradient behind character
                                RadialGradient(
                                    gradient: gradientForCharacter(characters[index].name),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 220
                                )
                                
                                // Character image with memory optimization
                                if abs(index - selectedCharacterIndex) <= 1 {
                                    // Only load images for current and adjacent cards
                                    Image(characters[index].imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 385)
                                        .clipped()
                                } else {
                                    // Placeholder for distant cards
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 385)
                                }
 
                                 // Bottom fade for image
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.clear,Color.clear, Color.black, Color.black, Color.black]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(height: 250)
                                }
                            }
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                .onChange(of: selectedCharacterIndex) { _ in
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Set the character and auto-play preview
                    let selectedCharacter = characters[selectedCharacterIndex]
                    speechManager.currentCharacter = selectedCharacter
                    let sampleRoast = getSampleRoast(for: selectedCharacter.name)
                    speechManager.speakRoast(sampleRoast, isPreview: true)
                    
                    // Log memory after character change
                    print("📊 Memory after character selection:")
                    speechManager.logMemoryAndCacheStatus()
                }
                
                Spacer()
                
                // Bottom section with title, description, and button
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(characters[selectedCharacterIndex].name.uppercased())
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(characters[selectedCharacterIndex].description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 40)
                            .frame(height: 40)
                    }
                    
                    Button(action: {
                        if selectedCharacterIndex == 0 || hasPremium {
                            characterViewModel.selectCharacter(characters[selectedCharacterIndex])
                        } else {
                            // Show paywall for premium characters
                            showPaywall = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(selectedCharacterIndex == 0 || hasPremium ? "SET" : "UPGRADE TO PREMIUM")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            // Check premium status
            Purchases.shared.getCustomerInfo { customerInfo, error in
                hasPremium = customerInfo?.entitlements.active.keys.contains("premium") ?? false
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
    
    private func getSampleRoast(for characterName: String) -> String {
        // Use specific preview roasts for each character
        switch characterName {
        case "Drill Sergeant":
            return "PATHETIC! I've seen more intensity in a chess match!"
        case "British Narrator":
            return "Here we observe a creature that has mastered the art of calorie conservation."
        case "Your Ex (Female)":
            return "Just like old times - all talk, no action."
        case "Your Ex (Male)":
            return "Bro, your form is still terrible and you're still not listening to my advice. Typical."
        default:
            return "Time to get roasted!"
        }
    }
}
    
    struct HorizontalCharacterCarousel: View {
        let characters: [Character]
        @Binding var selectedIndex: Int
        let speechManager: ElevenLabsManager
        let onCharacterSelect: (Character) -> Void
        
        @State private var dragOffset: CGFloat = 0
        @State private var currentOffset: CGFloat = 0
        
        var body: some View {
            GeometryReader { geometry in
                let cardWidth: CGFloat = 280
                let cardSpacing: CGFloat = 20
                let centerX = geometry.size.width / 2
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: cardSpacing) {
                        ForEach(0..<characters.count * 3, id: \.self) { index in
                            CharacterCarouselCard(
                                index: index,
                                characters: characters,
                                cardWidth: cardWidth,
                                cardSpacing: cardSpacing,
                                centerX: centerX,
                                currentOffset: currentOffset,
                                dragOffset: dragOffset,
                                speechManager: speechManager,
                                onCharacterSelect: onCharacterSelect,
                                onTap: { snapToCard(at: index, cardWidth: cardWidth, cardSpacing: cardSpacing) }
                            )
                        }
                    }
                    .offset(x: currentOffset + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragOffset = gesture.translation.width
                            }
                            .onEnded { gesture in
                                let cardStep = cardWidth + cardSpacing
                                let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                                let newOffset = currentOffset + gesture.translation.width + velocity * 0.1
                                
                                let targetIndex = -round(newOffset / cardStep)
                                let clampedIndex = max(CGFloat(characters.count), min(CGFloat(characters.count * 2 - 1), targetIndex))
                                
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentOffset = -clampedIndex * cardStep
                                    dragOffset = 0
                                }
                                
                                handleInfiniteLoop(cardStep: cardStep)
                            }
                    )
                }
                .scrollDisabled(true)
            }
            .frame(height: 400)
            .onAppear {
                let cardStep: CGFloat = 280 + 20 // cardWidth + cardSpacing
                currentOffset = -CGFloat(characters.count) * cardStep
            }
        }
        
        private func snapToCard(at index: Int, cardWidth: CGFloat, cardSpacing: CGFloat) {
            let cardStep = cardWidth + cardSpacing
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentOffset = -CGFloat(index) * cardStep
                dragOffset = 0
            }
        }
        
        private func handleInfiniteLoop(cardStep: CGFloat) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                let minThreshold = -CGFloat(characters.count * 2 - 1) * cardStep
                let maxThreshold = -CGFloat(characters.count + 1) * cardStep
                
                if currentOffset <= minThreshold {
                    currentOffset += CGFloat(characters.count) * cardStep
                } else if currentOffset >= maxThreshold {
                    currentOffset -= CGFloat(characters.count) * cardStep
                }
            }
        }
    }
    
    struct CharacterCarouselCard: View {
        let index: Int
        let characters: [Character]
        let cardWidth: CGFloat
        let cardSpacing: CGFloat
        let centerX: CGFloat
        let currentOffset: CGFloat
        let dragOffset: CGFloat
        let speechManager: ElevenLabsManager
        let onCharacterSelect: (Character) -> Void
        let onTap: () -> Void
        
        var body: some View {
            let characterIndex = index % characters.count
            let character = characters[characterIndex]
            let cardCenterX = CGFloat(index) * (cardWidth + cardSpacing) + cardWidth / 2
            let distanceFromCenter = abs(cardCenterX + currentOffset + dragOffset - centerX)
            let normalizedDistance = min(distanceFromCenter / (cardWidth + cardSpacing), 1.0)
            let isCenter = distanceFromCenter < cardWidth / 2
            
            CharacterCardView(
                character: character,
                isSelected: isCenter,
                speechManager: speechManager
            ) {
                onCharacterSelect(character)
            }
            .frame(width: cardWidth, height: 400)
            .scaleEffect(1.0 - normalizedDistance * 0.1)
            .opacity(1.0 - normalizedDistance * 0.3)
            .onTapGesture {
                onTap()
            }
        }
    }
    
    struct CharacterCardView: View {
        let character: Character
        let isSelected: Bool
        let speechManager: ElevenLabsManager
        let onSelect: () -> Void
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: gradientForCharacter(character.name),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.top, 20)

                
                VStack(spacing: 0) {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 250)
                        
                        if character.imageName == "drill" ||
                            character.imageName == "narrator" ||
                            character.imageName == "female-ex" ||
                            character.imageName == "male-ex" {
                            Image(character.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: isSelected ? 290 : 270)
                                .clipped()
                                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: isSelected)
                                .offset(y: -15)

                        } else {
                            VStack {
                                Image(systemName: characterIcon(for: character.name))
                                    .font(.system(size: 80, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                                
                            }
                            .offset(y: 25)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Character Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(character.name.uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(character.description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            // Arrow indicators (inspired by reference image)
                            if !isSelected {
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Buttons row
                        HStack(spacing: 12) {
                            // Preview button
                            Button(action: {
                                let sampleRoast = getSampleRoast(for: character.name)
                                speechManager.speakRoast(sampleRoast, isPreview: true)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: speechManager.isSpeaking ? "speaker.wave.2.fill" : "play.circle.fill")
                                        .font(.body)
                                    Text("PREVIEW")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .disabled(speechManager.isSpeaking)
                            
                            // Set as Roaster button
                            Button(action: {
                                onSelect()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.body)
                                    Text("SET")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .cornerRadius(20)
        }
        
        private func gradientForCharacter(_ name: String) -> Gradient {
            switch name {
            case "Drill Sergeant":
                return Gradient(colors: [Color.green, Color.black])
            case "British Narrator":
                return Gradient(colors: [Color.blue, Color.indigo])
            case "Your Ex":
                return Gradient(colors: [Color.purple, Color.pink])
            case "The Savage":
                return Gradient(colors: [Color.red, Color.orange])
            default:
                return Gradient(colors: [Color.gray, Color.black])
            }
        }
        
        private func characterIcon(for name: String) -> String {
            switch name {
            case "Drill Sergeant":
                return "shield.fill"
            case "British Narrator":
                return "mic.fill"
            case "Your Ex":
                return "heart.slash.fill"
            case "The Savage":
                return "flame.fill"
            default:
                return "person.fill"
            }
        }
        
        private func getSampleRoast(for characterName: String) -> String {
            switch characterName {
            case "Drill Sergeant":
                return "Drop and give me twenty! Your workout performance is more disappointing than a broken treadmill!"
            case "British Narrator":
                return "And here we observe the human in their natural habitat, avoiding exercise with the dedication of a professional couch potato."
            case "Your Ex":
                return "Still working out alone, I see. At least the gym equipment won't ghost you like I did."
            case "The Savage":
                return "Your fitness level is so low, even your shadow is embarrassed to follow you around."
            default:
                return "Time to get roasted!"
            }
        }
    }
 
