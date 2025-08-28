//
//  ExploreTab.swift
//  Burned
//
//  Created by Raghav Sethi on 28/08/25.
//
import SwiftUI

struct ExploreTab: View {
    @State private var selectedCharacterIndex = 0
    @StateObject private var speechManager = ElevenLabsManager.shared
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    private let characters = Character.allCharacters
    
    private let challenges = [
        "Survive 30 days without excuses",
        "Beat your laziest week record",
        "Burn more calories than you make excuses",
        "Take more steps than selfies"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Character Card Deck Section
                    VStack(spacing: 20) {
                        Text("Choose Your Roaster")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        CharacterCardDeckView(
                            characters: characters,
                            selectedIndex: $selectedCharacterIndex,
                            speechManager: speechManager
                        ) { character in
                            characterViewModel.selectCharacter(character)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Challenges")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(challenges, id: \.self) { challenge in
                                    ChallengeCardView(challenge: challenge)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
}

struct CharacterCardDeckView: View {
    let characters: [Character]
    @Binding var selectedIndex: Int
    let speechManager: ElevenLabsManager
    let onCharacterSelect: (Character) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.8
            let cardHeight: CGFloat = 450
            
            ZStack {
                ForEach(Array(characters.enumerated().reversed()), id: \.offset) { index, character in
                    CharacterCardView(
                        character: character,
                        isSelected: selectedIndex == index,
                        speechManager: speechManager
                    ) {
                        onCharacterSelect(character)
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .scaleEffect(selectedIndex == index ? 1.0 : 0.9)
                    .opacity(1.0)  // Force full opacity for all cards
                    .offset(x: offsetForCard(at: index, cardWidth: cardWidth))
                    .zIndex(selectedIndex == index ? 1000 : Double(characters.count - index))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedIndex)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .frame(height: cardHeight)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold {
                            // Swipe right - previous card
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedIndex = max(0, selectedIndex - 1)
                            }
                        } else if value.translation.width < -threshold {
                            // Swipe left - next card
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedIndex = min(characters.count - 1, selectedIndex + 1)
                            }
                        }
                    }
            )
        }
        .frame(height: 450)
        .padding(.horizontal, 20)
    }
    
    private func offsetForCard(at index: Int, cardWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = cardWidth * 0.15
        let baseOffset = CGFloat(index - selectedIndex) * spacing
        
        if index == selectedIndex {
            return 0
        } else if index < selectedIndex {
            // Cards to the left - stack them behind
            return baseOffset - 20
        } else {
            // Cards to the right - show preview sliver
            return baseOffset + 20
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
            
            VStack(spacing: 0) {
                // Character Image Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 250)
                    
                    // Placeholder for character image
                    VStack {
                        Image(systemName: characterIcon(for: character.name))
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Image Placeholder")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
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
                            speechManager.speakRoast(sampleRoast)
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
                                Text("SET AS ROASTER")
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
