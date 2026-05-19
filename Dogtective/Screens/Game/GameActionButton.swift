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
        let cinematic = dialogStateViewModel.isCinematic
        HStack(spacing: 20) {

            ImageButton(label: "speechButton", type: .primary, size: .large) {
                dialogStateViewModel.isChat = .chat
            }
            .opacity((dialogStateViewModel.isChat == .bubble && !cinematic) ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.05), value: dialogStateViewModel.isChat)
            .animation(.easeInOut(duration: 0.05), value: cinematic)
            .disabled(dialogStateViewModel.isChat != .bubble || cinematic)

            ImageButton(label: "magnifyingglassButton", type: .primary, size: .large) {
                NotificationCenter.default.post(name: .magnifyingButtonTapped, object: nil)
            }
            .opacity(cinematic ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.05), value: cinematic)
            .disabled(cinematic)
        }
    }
}
