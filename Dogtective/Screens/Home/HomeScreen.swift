//
//  HomeScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

struct HomeScreen: View {
    // State inherited from your settings logic
    @State private var isMusicOn = true
    @State private var isHapticsOn = true
    @State private var showingLevelScreen = false
    
    var body: some View {
        ZStack {
            // 1. Background Landing Page
            Image("BG_landing_page")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 2. Top Right Settings Buttons
            VStack {
                HStack(spacing: 15) {
                    Spacer()
                    
                    Button(action: {
                        isHapticsOn.toggle()
                    }) {
                        Image(isHapticsOn ? "haptics_on" : "haptics_off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    
                    Button(action: {
                        isMusicOn.toggle()
                    }) {
                        Image(isMusicOn ? "music_on" : "music_off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
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
                // Play Button
                Button(action: {
                    showingLevelScreen = true
                }) {
                    Image("play_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                }
                .padding(.bottom, 50)
            }
        }
        // Navigation or FullScreenCover to LevelScreen
        .fullScreenCover(isPresented: $showingLevelScreen) {
            LevelScreen()
        }
    }
}
