//
//  LevelDetail.swift
//  Dogtective
//
//  Created by Bee Wijaya on 17/05/26.
//

import SwiftUI

// MARK: - Level Detail Overlay
struct LevelDetailOverlay: View {
    // MARK: - ViewModel
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    @EnvironmentObject var backpackStateViewModel: BackpackStateViewModel
    @EnvironmentObject var questStateViewModel: QuestStateViewModel
    
    // MARK: - Local Property
    let data: LevelData
    var onClose: () -> Void
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            HStack(spacing: 40) {
                
                // MARK: - Poster Section
                ZStack {
                    Group {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 300, height: 300)
                            .blur(radius: 25)
                        
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 180, height: 180)
                            .blur(radius: 15)
                    }
                    
                    Image("poster_level_\(data.id)")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200)
                        .rotationEffect(.degrees(-4))
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                }
                .frame(maxWidth: 250)
                
                // MARK: - Text Section
                VStack(alignment: .leading, spacing: 15) {
                    Text(data.title)
                        .font(.custom("AvenirNext-Bold", size: 36))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(data.description)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: 320, alignment: .leading)
                    
                    
                    if gameSettingsViewModel.currentLevel == data.id {
                        // IF Game ever saved / investigated
                        // 2 Buttons ( Resume, New Game )
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    pageStateViewModel.state = .loading
                                }
                                print("Resuming level \(data.id)")
                            }) {
                                Image("resume_game_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                            }
                            .padding(.top, 10)
                            
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    pageStateViewModel.state = .loading
                                }
                                print("New game level \(data.id)")
                                // reset current level
                                gameSettingsViewModel.reset()
                                backpackStateViewModel.reset()
                                questStateViewModel.reset()

                                // save current level
                                gameSettingsViewModel.currentLevel = data.id
                                gameSettingsViewModel.save()
                            }) {
                                Image("new_game_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                            }
                            .padding(.top, 10)
                        }
                    } else {
                        // IF Game is totally new
                        // Button INVESTIGATE
                        Button(action: {
                            // render loading
                            withAnimation(.easeInOut(duration: 0.5)) {
                                pageStateViewModel.state = .loading
                            }
                            
                            // save current level
                            gameSettingsViewModel.currentLevel = data.id
                            gameSettingsViewModel.save()
                            print("Investigating level \(data.id)")
                            
                        }) {
                            Image("investigateButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                        }
                        .padding(.top, 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
