import SwiftUI

struct CharacterSelectionView: View {
    @Binding var selectedCharacter: Character?
    @State private var currentIndex = 0
    @State private var cardAnimationComplete = false
    @Namespace private var animation
    
    let characters = Character.allCharacters
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title
                    Text("SELECT YOUR COACH")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 10)
                        .shadow(color: .blue, radius: 5)
                        .padding(.top, 60)
                    
                    // Character carousel
                    TabView(selection: $currentIndex) {
                        ForEach(0..<characters.count, id: \.self) { index in
                            CharacterCard(
                                character: characters[index],
                                isSelected: currentIndex == index,
                                cardAnimationComplete: cardAnimationComplete,
                                geometry: geometry
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: geometry.size.height * 0.6)
                    .onChange(of: currentIndex) { _ in
                        cardAnimationComplete = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                                cardAnimationComplete = true
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                                cardAnimationComplete = true
                            }
                        }
                    }
                    
                    // Character info
                    VStack(spacing: 20) {
                        Text(characters[currentIndex].name.uppercased())
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .animation(.spring(), value: currentIndex)
                        
                        Text(characters[currentIndex].description)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .animation(.spring(), value: currentIndex)
                        
                        // Select button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedCharacter = characters[currentIndex]
                            }
                        }) {
                            HStack {
                                Text("SELECT")
                                    .font(.system(size: 20, weight: .bold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .white.opacity(0.5), radius: 10)
                            )
                        }
                        .scaleEffect(1.0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                                // Haptic feedback would go here
                            }
                        }
                    }
                    .padding(.bottom, 50)
                    
                    // Page indicators
                    HStack(spacing: 10) {
                        ForEach(0..<characters.count, id: \.self) { index in
                            Circle()
                                .fill(currentIndex == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct CharacterCard: View {
    let character: Character
    let isSelected: Bool
    let cardAnimationComplete: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            // Character image
            ZStack(alignment: .bottom) {
                // Background for image
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(
                        width: geometry.size.width * 0.7, 
                        height: geometry.size.width * 0.7
                    )
                
                // Actual character image
                Image(character.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width * 0.7, 
                        height: geometry.size.width * (isSelected && cardAnimationComplete ? 0.85 : 0.7)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .scaleEffect(isSelected ? 1.0 : 0.8)
            .opacity(isSelected ? 1.0 : 0.6)
            .shadow(color: isSelected ? .blue : .clear, radius: 20)
            .shadow(color: isSelected ? .purple : .clear, radius: 10)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
        }
    }
}

#Preview {
    CharacterSelectionView(selectedCharacter: .constant(nil))
}