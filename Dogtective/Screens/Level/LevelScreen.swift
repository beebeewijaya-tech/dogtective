//
//  LevelScreen.swift
//  Dogtective
//
//  Created by Michael David Sin on 07/05/26.
//

import SwiftUI

struct LevelScreen: View {
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isMusicOn = true
    @State private var isHapticsOn = true
    @State private var selectedLevel: Int? = nil
    
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
            
            Image("levelpage_bg")
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
            
            HStack {
                
                Button(action: {
                    if selectedLevel != nil {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedLevel = nil
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    Image("backButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    
                    Button(action: {
                        isHapticsOn.toggle()
                    }) {
                        Image(
                            isHapticsOn
                            ? "haptics_on"
                            : "haptics_off"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    }
                    
                    Button(action: {
                        isMusicOn.toggle()
                    }) {
                        Image(
                            isMusicOn
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
}

// MARK: - Level Detail Overlay

struct LevelDetailOverlay: View {
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
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
                    
                    Button(action: {
                        pageStateViewModel.selectedLevel = data.id
                        withAnimation(.easeInOut(duration: 0.5)) {
                            pageStateViewModel.state = .loading
                        }
                        print("Investigating level \(data.id)")
                    }) {
                        Image("investigateButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LevelData: Identifiable {
    let id: Int
    let title: String
    let description: String
}

// MARK: - Preview

struct LevelScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        LevelScreen()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
