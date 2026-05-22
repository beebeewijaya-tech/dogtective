//
//  AppDialog.swift
//  Dogtective
//
//  Created by Bee Wijaya on 14/05/26.
//

import SwiftUI

struct AppDialog: View {
    var name: String
    var text: String
    var image: String? = nil
    var onClose: () -> Void = {}
    
    // MARK: - State
    @State var nameDisplay: String = ""
    @State var textDisplay: String = ""
    @State var isAnimating: Bool = true
    
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    private let audioManager = AudioManager.shared
    
    private func animateName() async {
        for n in name.uppercased() {
            guard isAnimating else { break }
            nameDisplay += String(n)
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
    
    private func animateText() async {
        
        audioManager.playTypingSound(isSoundEnabled: gameSettingsViewModel.soundEnabled)
        
        for t in text.capitalized {
            guard isAnimating else { break }
            textDisplay += String(t)
            try? await Task.sleep(for: .milliseconds(20))
        }
        
        if isAnimating {
            audioManager.stopTypingSound()
            isAnimating = false
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .topLeading) {
                // 1) character sprite, sitting behind everything.
                //    half-body effect = clip the bottom against the text bubble.
                if let image = image {
                    Image(image)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 160, alignment: .top)
                        .clipped()
                        .offset(x: 20, y: -90)
                        .zIndex(0)
                }
                
                // 2) main text bubble.
                Image("dialog_text_bubble")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        VStack(alignment: .leading) {
                            Text(isAnimating ? textDisplay : text.capitalized)
                                .foregroundStyle(.black)
                                .font(.default)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                    }
                    .padding(.top, 25)
                    .zIndex(1)
                
                // 3) name plate on top of everything.
                Image("dialog_head_bubble")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 37)
                    .overlay(alignment: .center) {
                        Text(isAnimating ? nameDisplay : name.uppercased())
                            .foregroundStyle(.white)
                            .passerOneStyle(size: 24)
                    }
                    .offset(x: 20, y: 8)
                    .zIndex(2)
            }
        }
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if isAnimating {
                
                isAnimating = false
                nameDisplay = name.uppercased()
                textDisplay = text.capitalized
                AudioManager.shared.stopTypingSound()
            } else {
                
                AudioManager.shared.stopTypingSound()
                onClose()
            }
        }
        .task {
            
            audioManager.playSFX(
                fileName: "woof_sound",
                isSoundEnabled: gameSettingsViewModel.soundEnabled
            )
            
            await animateName()
            await animateText()
        }
        
        .onDisappear {
            AudioManager.shared.stopTypingSound()
        }
    }
}
