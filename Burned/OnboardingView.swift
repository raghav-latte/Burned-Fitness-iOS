//
//  OnboardingView.swift
//  Burned
//
//  Created by Raghav Sethi on 30/08/25.
//

import SwiftUI
import HealthKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var userName: String = ""
    @State private var selectedIntensity: Double = 3.0
    @State private var selectedCharacter: Character?
    @State private var triggeringWords: [String] = []
    @State private var motivationReasons: [String] = []
    @State private var wakeUpTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @State private var sleepTime = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var hasCompletedOnboarding = false
    @Binding var showOnboarding: Bool
    @EnvironmentObject var characterViewModel: CharacterViewModel
    
    private let totalPages = 8
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                OnboardingProgressBar(currentPage: currentPage, totalPages: totalPages)
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                
                // Page Content
                TabView(selection: $currentPage) {
                    WhyBurnedPage(onNext: nextPage)
                        .tag(0)
                    
                    NameInputPage(
                        userName: $userName,
                        onNext: nextPage
                    )
                    .tag(1)
                    
                    IntensitySelectionPage(
                        selectedIntensity: $selectedIntensity,
                        onNext: nextPage
                    )
                    .tag(2)
                    
                    CharacterSelectionPage(
                        selectedCharacter: $selectedCharacter,
                        onNext: nextPage
                    )
                    .tag(3)
                    
                    TriggeringWordsPage(
                        triggeringWords: $triggeringWords,
                        onNext: nextPage
                    )
                    .tag(4)
                    
                    MotivationQuestionnairePage(
                        motivationReasons: $motivationReasons,
                        onNext: nextPage
                    )
                    .tag(5)
                    
                    WakeupSleepTimesPage(
                        wakeUpTime: $wakeUpTime,
                        sleepTime: $sleepTime,
                        onNext: nextPage
                    )
                    .tag(6)
                    
                    PermissionsPage(
                        onComplete: completeOnboarding
                    )
                    .tag(7)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            // Disable swipe gesture - use buttons only
                        }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func nextPage() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if currentPage < totalPages - 1 {
                currentPage += 1
            }
        }
    }
    
    private func completeOnboarding() {
        // Save onboarding data
        if let character = selectedCharacter {
            characterViewModel.selectCharacter(character)
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(selectedIntensity, forKey: "roastIntensity")
        UserDefaults.standard.set(triggeringWords, forKey: "triggeringWords")
        UserDefaults.standard.set(motivationReasons, forKey: "motivationReasons")
        UserDefaults.standard.set(wakeUpTime, forKey: "wakeUpTime")
        UserDefaults.standard.set(sleepTime, forKey: "sleepTime")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Now that onboarding is complete, set up notifications
        NotificationManager.shared.requestPermission()
        NotificationManager.shared.scheduleDailyNoWorkoutRoast()
        NotificationManager.shared.scheduleBackgroundWorkoutCheck()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showOnboarding = false
        }
    }
}

struct OnboardingProgressBar: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(currentPage + 1) / CGFloat(totalPages), height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
            }
        }
        .frame(height: 8)
    }
}