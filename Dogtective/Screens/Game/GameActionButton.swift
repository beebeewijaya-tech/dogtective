//
//  GameActionButton.swift
//  Dogtective
//
//  Created by Bee Wijaya on 07/05/26.
//

import SwiftUI

struct GameActionButton: View {
    // MARK: - ViewModel
    @EnvironmentObject var dialogStateViewModel: DialogStateViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            
            Button(action: {
                dialogStateViewModel.isChat = .chat
            }) {
                Image("speechButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
            .opacity(dialogStateViewModel.isChat == .bubble ? 1 : 0.0)
            .animation(.easeInOut(duration: 0.1), value: dialogStateViewModel.isChat)
            .disabled(dialogStateViewModel.isChat != .bubble)
            
            Button(action: {
                
            }) {
                Image("magnifyingglassButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
        }
    }
}
