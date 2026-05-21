//
//  HomeScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

struct HomeScreen: View {
    // MARK: - ViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    
    
    // MARK: - State
    // State inherited from your settings logic
    @State private var isHapticsOn = true
    @State private var showingLevelScreen = false
    private let audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            // 1. Background Landing Page
            Image("BG_landing_page")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 2. Top Right Settings Buttons
            VStack {
                AppSettings()
                Spacer()
            }
            
            // 3. Center Content (Logo and Play Button)
            VStack(spacing: 20) {
                Spacer()
                ZStack {
                    // Dogtective Logo
                    Image("BG_level_page")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500)
                    
                    Image("game_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500)
                    
                }
                // 4. Play Button
                Button(action: {
                    showingLevelScreen = true
                }) {
                    Image("play_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                }
                .padding(.bottom, 50)
                
                // 5. Backsound
                .onAppear {
                    if gameSettingsViewModel.soundEnabled {
                        audioManager.playMusic(fileName: "dogtective_song" )
                    }
                }
                .onChange(of: gameSettingsViewModel.soundEnabled) { oldValue, newValue in
                    audioManager.toggleMusic(isOn: newValue)
                }
                .fullScreenCover(isPresented: $showingLevelScreen) {
                    LevelScreen()
                }
            }
        }
    }
}

