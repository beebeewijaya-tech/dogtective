//
//  StampComponent.swift
//  Dogtective
//
//  Created by Michael David Sin on 22/05/26.
//

import SwiftUI

struct StampComponent: View {
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    
    var isJustFinished: Bool
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            if isJustFinished {
                // FASE ANIMASI (Bisa diatur scale & offset-nya sendiri)
                AppLottie(
                    avatarName: "stamp",
                    freezeAtEnd: false,
                    isTransparent: true
                ) {
                    onAnimationComplete()
                }
                .scaleEffect(1.5) // Perbesar dikit (misal 1.2x)
                .offset(y: -65)   // Arahin ke atas dikit (nilai negatif = ke atas)
                .onAppear {
                    AudioManager.shared.playSFX(
                        fileName: "stamp_sound",
                        isSoundEnabled: gameSettingsViewModel.soundEnabled
                    )
                }
            } else {
                // FASE STATIS (Biarkan sesuai pengaturan sebelumnya)
                Image("stamped")
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity.animation(.easeIn(duration: 0.5)))
            }
        }
    }
}
