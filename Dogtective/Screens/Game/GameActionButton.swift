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
        HStack {
            ImageButton(label: "chat_bubble", type: .tertiary, size: .small) {
                dialogStateViewModel.setState(.chat)
            }
            .opacity(dialogStateViewModel.isChat == .bubble ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.1), value: dialogStateViewModel.isChat)
            .disabled(dialogStateViewModel.isChat != .bubble)
            
            ImageButton(label: "magnifying_glass", type: .tertiary, size: .small) {
                
            }
        }
    }
}
