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
            
            ImageButton(label: "speechButton", type: .primary, size: .large) {
                dialogStateViewModel.isChat = .chat
            }
            .opacity(dialogStateViewModel.isChat == .bubble ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.05), value: dialogStateViewModel.isChat)
            .disabled(dialogStateViewModel.isChat != .bubble)
            
            ImageButton(label: "magnifyingglassButton", type: .primary, size: .large) {
                NotificationCenter.default.post(name: .magnifyingButtonTapped, object: nil)
            }
        }
    }
}
