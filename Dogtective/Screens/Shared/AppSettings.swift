//
//  AppSettings.swift
//  Dogtective
//
//  Created by Bee Wijaya on 17/05/26.
//

import SwiftUI


struct AppSettings: View {
    // MARK: - ViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    
    // MARK: - Props
    var isBack: Bool = false
    var isBackAction: () -> Void = { }
    
    
    var body: some View {
        HStack {
            if isBack {
                Button(action: {
                    isBackAction()
                }) {
                    Image("backButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
            }
            
            
            Spacer()
            
            HStack(spacing: 15) {
                
                Button(action: {
                    gameSettingsViewModel.hapticsEnabled.toggle()
                    gameSettingsViewModel.save()
                }) {
                    Image(
                        gameSettingsViewModel.hapticsEnabled
                        ? "haptics_on"
                        : "haptics_off"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                }
                
                Button(action: {
                    gameSettingsViewModel.soundEnabled.toggle()
                    gameSettingsViewModel.save()
                }) {
                    Image(
                        gameSettingsViewModel.soundEnabled
                        ? "music_on"
                        : "music_off"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .zIndex(999)
    }
}
