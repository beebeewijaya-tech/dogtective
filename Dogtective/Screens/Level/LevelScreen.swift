//
//  LevelScreen.swift
//  Dogtective
//
//  Created by Michael David Sin on 07/05/26.
//

import SwiftUI

struct LevelScreen: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    
    // MARK: - ViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    @EnvironmentObject var levelViewModel: LevelViewModel
    @EnvironmentObject var cutsceneViewModel: CutsceneViewModel
    
    // MARK: - State
    @State private var selectedLevel: Int? = nil
    @State private var unlockedLevels: Int = 1
    
    private let audioManager = AudioManager.shared
    
    // MARK: - Local immutable property
    let rotations: [Double] = [-5.0, 6.0, -1.0, -8.0, 5.0]
    let yOffsets: [CGFloat] = [0.0, -15.0, 5.0, 20.0, -12.0]
    let lockedColor = Color(
        red: 56/255,
        green: 24/255,
        blue: 0/255
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Image("BG_level_page")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            ZStack {
                
                VStack {
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(1...10, id: \.self) { index in
                                let isOpened = index <= unlockedLevels
                                let level = levelViewModel.getLevelById(id: index)
                                Button(action: {
                                    audioManager.playSFX(
                                        fileName: "selectmenu_sound",
                                        isSoundEnabled: gameSettingsViewModel.soundEnabled
                                    )
                                    
                                    if isOpened {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            levelViewModel.currentLevel = index
                                        }
                                    }
                                }) {
                                    ZStack {
                                        
                                        Image("poster_level_\(index)")
                                            .resizable()
                                            .scaledToFit()
                                            .colorMultiply(isOpened ? .white : lockedColor)
                                            .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                                        
                                        
                                        // MARK: - Stamp Placement
                                        if level.finished {
                                            StampComponent(
                                                isJustFinished: pageStateViewModel.state == .finished,
                                                onAnimationComplete: {
                                                    pageStateViewModel.state = .level
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        AudioManager.shared.playSFX(
                                                            fileName: "cheer_sound",
                                                            isSoundEnabled: gameSettingsViewModel.soundEnabled
                                                        )
                                                        withAnimation(.easeInOut(duration: 1.0)) {
                                                            if !gameSettingsViewModel.levelFinished.contains(index) {
                                                                gameSettingsViewModel.levelFinished.append(index)
                                                                gameSettingsViewModel.save()
                                                                unlockedLevels = index + 1
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                            )
                                            .frame(width: 150, height: 150)
                                            .zIndex(2)
                                        }
                                    }
                                    .frame(width: 200, height: 280)
                                    .scaleEffect(0.9)
                                    .rotationEffect(.degrees(rotations[index % rotations.count]))
                                    .offset(y: yOffsets[index % yOffsets.count])
                                }
                            }
                        }
                        .padding(.horizontal, 80)
                    }
                    
                    Spacer()
                }
                .opacity(levelViewModel.currentLevel == nil ? 1 : 0)
                .allowsHitTesting(levelViewModel.currentLevel == nil)
                .animation(
                    .easeInOut(duration: 0.2),
                    value: levelViewModel.currentLevel
                )
                
                if let levelInfo = levelViewModel.getCurrentLevel() {
                    LevelDetailOverlay(
                        data: levelInfo
                    ) {
                        
                        audioManager.playSFX(
                            fileName: "selectmenu_sound",
                            isSoundEnabled: gameSettingsViewModel.soundEnabled
                        )
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            levelViewModel.currentLevel = nil
                        }
                    }
                    .zIndex(10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Fixed Header
            AppSettings(isBack: true) {
                
                audioManager.playSFX(
                    fileName: "selectmenu_sound",
                    isSoundEnabled: gameSettingsViewModel.soundEnabled
                )
                if levelViewModel.getCurrentLevel() != nil {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        levelViewModel.currentLevel = nil // set to empty
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        pageStateViewModel.state = .home
                    }
                    dismiss()
                }
            }
        }
        .onAppear {
            unlockedLevels = gameSettingsViewModel.levelFinished.count + 1
            if gameSettingsViewModel.currentLevel >= 0 {
                levelViewModel.startLevel(id: gameSettingsViewModel.currentLevel)
            }
        }
    }
}

// MARK: - Preview
struct LevelScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        LevelScreen()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
