//
//  GameQuit.swift
//  Dogtective
//
//  Created by Michael David Sin on 18/05/26.
//

import SwiftUI

struct GameQuit: View {
    
    @Binding var showQuitConfirmation: Bool
    @Binding var isPaused: Bool
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    
    private let audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            Image("quit_popup")
                .resizable()
                .scaledToFill()
                .frame(width: 420, height: 240)
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 8)
            
            HStack(spacing: -5) {
                
                Button(action: {
                    // SUDAH TEPAT!
                    audioManager.playSFX(
                        fileName: "selectmenu_sound",
                        isSoundEnabled: gameSettingsViewModel.soundEnabled
                    )
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showQuitConfirmation = false
                        isPaused = false
                    }
                }) {
                    Image("quit_no")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 45)
                }
                
                Button(action: {

                    audioManager.playSFX(
                        fileName: "selectmenu_sound",
                        isSoundEnabled: gameSettingsViewModel.soundEnabled
                    )
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showQuitConfirmation = false
                        isPaused = false
                        pageStateViewModel.state = .level
                    }
                }) {
                    Image("quit_yes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 45)
                }
                
            }
            .offset(y: 35)
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }
}
