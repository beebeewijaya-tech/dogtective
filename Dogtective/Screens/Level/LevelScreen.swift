//
//  LevelScreen.swift
//  Dogtective
//
//  Created by Michael David Sin on 07/05/26.
//

import SwiftUI

// MARK: - Level Info
struct LevelData: Identifiable {
    let id: Int
    let title: String
    let description: String
}

struct LevelScreen: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    
    // MARK: - ViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    
    
    // MARK: - State
    @State private var selectedLevel: Int? = nil
    
    
    // MARK: - Local immutable property
    let rotations: [Double] = [-5.0, 6.0, -1.0, -8.0, 5.0]
    let yOffsets: [CGFloat] = [0.0, -15.0, 5.0, 20.0, -12.0]
    let lockedColor = Color(
        red: 56/255,
        green: 24/255,
        blue: 0/255
    )
    let allLevels: [LevelData] = [
        LevelData(id: 1, title: "The Missing Bones", description: "Something happens in a quiet sunny days in Pawland district. Bones that are safely kept are suddenly missing..."),
        LevelData(id: 2, title: "The Barking Ghost", description: "Rumors say a spooky figure is haunting the backyard. It's time to investigate what's really going on!"),
        LevelData(id: 3, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 4, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 5, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 6, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 7, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 8, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 9, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
        LevelData(id: 10, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?"),
    ]
    
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
                                let isOpened = index == 1
                                
                                Button(action: {
                                    if isOpened {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            selectedLevel = index
                                        }
                                    }
                                }) {
                                    
                                    ZStack {
                                        Image("poster_level_\(index)")
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(0.9)
                                            .colorMultiply(
                                                isOpened ? .white : lockedColor
                                            )
                                            .shadow(
                                                color: .black.opacity(0.3),
                                                radius: 3,
                                                x: 2,
                                                y: 2
                                            )
                                            .rotationEffect(
                                                .degrees(
                                                    rotations[index % rotations.count]
                                                )
                                            )
                                            .offset(
                                                y: yOffsets[index % yOffsets.count]
                                            )
                                    }
                                    .frame(width: 200, height: 280)
                                }
                            }
                        }
                        .padding(.horizontal, 80)
                    }
                    
                    Spacer()
                }
                .opacity(selectedLevel == nil ? 1 : 0)
                .allowsHitTesting(selectedLevel == nil)
                .animation(
                    .easeInOut(duration: 0.2),
                    value: selectedLevel
                )
                
                if let index = selectedLevel,
                   let levelInfo = allLevels.first(where: { $0.id == index }) {
                    LevelDetailOverlay(
                        data: levelInfo
                    ) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedLevel = nil
                        }
                    }
                    .zIndex(10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Fixed Header
            AppSettings(isBack: true) {
                // When back getting tap
                if selectedLevel != nil {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedLevel = nil
                    }
                } else {
                    dismiss()
                }
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
