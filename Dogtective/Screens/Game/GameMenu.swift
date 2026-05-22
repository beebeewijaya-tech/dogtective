//
//  GameMenu.swift
//  Dogtective
//
//  Created by Bee Wijaya on 07/05/26.
//

import SwiftUI

struct GameMenu: View {
    @EnvironmentObject var backpackStateViewModel: BackpackStateViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    
    @State private var isBackpackOpen = false
    @Binding var isPaused: Bool
    
    private let audioManager = AudioManager.shared
    
    let backpackItems = [
        "tissue", "siluet", "corn", "piece_of_corn",
        "fur", "dig", "billy", "fence"
    ]
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .trailing) {
                    if isBackpackOpen {
                        ZStack(alignment: .trailing) {
                            
                            Image("backpackBar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 45)
                                .offset(x: -5)
                            
                            HStack(spacing: 5) {
                                ForEach(backpackItems, id: \.self) { item in
                                    let collected = backpackStateViewModel.collectedKeys.contains(item)
                                    Image(collected ? "\(item)_on" : "\(item)_off")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .padding(.trailing, 50)
                            .padding(.leading, 15)
                        }
                        .transition(.asymmetric(
                            insertion: .offset(x: 350),
                            removal: .offset(x: 350)
                        ))
                    }
                }
                .frame(width: 400, height: 60, alignment: .trailing)
                .clipped()
                .zIndex(1)
                
                ZStack(alignment: .topTrailing) {
                    AppIcon(icon: "backpackButton", size: .medium) {
                        let wasOpen = isBackpackOpen
                        
                        if !wasOpen {
                            // 2. Update suara backpack
                            audioManager.playSFX(
                                fileName: "backpack_sound",
                                isSoundEnabled: gameSettingsViewModel.soundEnabled
                            )
                        }
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isBackpackOpen.toggle()
                        }
                        // Mark seen on close (open → close cycle clears badge).
                        if wasOpen {
                            backpackStateViewModel.markSeen()
                        }
                    }
                    
                    if backpackStateViewModel.hasUnseen {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Text("!")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 4, y: -4)
                    }
                }
                .padding(.trailing, 7.5)
                .offset(x: 18)
                .zIndex(2)
            }
            .frame(width: 430, height: 60, alignment: .trailing)
            
            AppIcon(icon: "pauseButton", size: .medium) {

                audioManager.playSFX(
                    fileName: "selectmenu_sound",
                    isSoundEnabled: gameSettingsViewModel.soundEnabled
                )
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPaused = true
                }
            }
        }
        
        .padding(.top, 20)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

// MARK: - Previews
struct GameMenu_Previews: PreviewProvider {
    static var previews: some View {
        GameMenu(isPaused: .constant(false))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
