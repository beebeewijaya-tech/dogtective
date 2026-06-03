//
//  GamePause.swift
//  Dogtective
//
//  Created by Michael David Sin on 18/05/26.
//

import SwiftUI

struct GamePause: View {
    // MARK: - Bindings
    @Binding var isPaused: Bool
    @Binding var showSaveToast: Bool
    @Binding var showTutorial: Bool
    
    // MARK: - ViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    
    // MARK: - State
    @State private var showQuitConfirmation = false
    private let audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    if !showQuitConfirmation {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPaused = false
                        }
                    }
                }
            if !showQuitConfirmation {
                
                ZStack {
                    Image("pause_popup")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 550, height: 320)
                        .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 10)
                    
                    HStack(spacing: 12) {
                        
                        Image("resume_poster_1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 230)
                            .padding(.leading, 10)
                        
                        VStack(spacing: 14) {
                            HStack(spacing: 20) {
                                
                                Button(action: {
                                    
                                    audioManager.playSFX(
                                            fileName: "selectmenu_sound",
                                            isSoundEnabled: gameSettingsViewModel.soundEnabled
                                        )
                                    gameSettingsViewModel.hapticsEnabled.toggle()
                                    gameSettingsViewModel.save()
                                }) {
                                    Image(gameSettingsViewModel.hapticsEnabled ? "haptics_on" : "haptics_off")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 55)
                                }
                                
                                Button(action: {
                                    
                                    audioManager.playSFX(
                                            fileName: "selectmenu_sound",
                                            isSoundEnabled: gameSettingsViewModel.soundEnabled
                                        )
                                    gameSettingsViewModel.soundEnabled.toggle()
                                    gameSettingsViewModel.save()
                                }) {
                                    Image(gameSettingsViewModel.soundEnabled ? "music_on" : "music_off")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 55)
                                }
                                
                                Button(action: {
                                    showTutorial = true
                                }) {
                                    Image("tutorial_btn_preview")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 55)
                                }
                            }
                            
                            Button(action: {
                                
                                audioManager.playSFX(
                                    fileName: "selectmenu_sound",
                                    isSoundEnabled: gameSettingsViewModel.soundEnabled
                                )
                                NotificationCenter.default.post(name: .saveGameRequested, object: nil)
                                
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isPaused = false
                                    showSaveToast = true
                                }
                            }) {
                                Image("saveButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 45)
                            }
                            
                            Button(action: {
                                
                                audioManager.playSFX(
                                    fileName: "selectmenu_sound",
                                    isSoundEnabled: gameSettingsViewModel.soundEnabled
                                )
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showQuitConfirmation = true
                                }
                            }) {
                                Image("quitButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 45)
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    .frame(width: 520, height: 320)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                
                                // Update suara tombol Back
                                audioManager.playSFX(
                                    fileName: "selectmenu_sound",
                                    isSoundEnabled: gameSettingsViewModel.soundEnabled
                                )
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isPaused = false
                                }
                            }) {
                                Image("backButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            .offset(x: -225, y: 29)
                        }
                        Spacer()
                    }
                    .frame(width: 520, height: 320)
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                
            } else {
                
                GameQuit(showQuitConfirmation: $showQuitConfirmation, isPaused: $isPaused)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .zIndex(100)
        .onAppear {

            audioManager.dimBackgroundMusic(isDimmed: true)
        }
        .onDisappear {

            audioManager.dimBackgroundMusic(isDimmed: false)
        }
    }
}
