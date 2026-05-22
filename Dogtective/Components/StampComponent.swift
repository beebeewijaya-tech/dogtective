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
        if isJustFinished {

            AppLottie(
                avatarName: "stamp_temporary",
                freezeAtEnd: false,
                isTransparent: true
            ) {
                onAnimationComplete()
            }
            .onAppear {

                AudioManager.shared.playSFX(
                    fileName: "stamp_sound",
                    isSoundEnabled: gameSettingsViewModel.soundEnabled
                )
            }
            
        } else {
            
            AppLottie(
                avatarName: "stamp_temporary",
                freezeAtEnd: true,
                isTransparent: true
            )
            
        }
    }
}
