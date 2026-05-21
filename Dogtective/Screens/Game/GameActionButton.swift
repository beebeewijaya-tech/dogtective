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
        // A dialog is already on screen — block both actions so a chat or a
        // second magnify dialog can't be stacked on top of it.
        let dialogOpen = dialogStateViewModel.dialog != nil
        HStack(spacing: 20) {

            ImageButton(label: "speechButton", type: .primary, size: .large) {
                dialogStateViewModel.isChat = .chat
            }
            .opacity((dialogStateViewModel.isChat == .bubble && !cinematic && !dialogOpen) ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.05), value: dialogStateViewModel.isChat)
            .animation(.easeInOut(duration: 0.05), value: cinematic)
            .animation(.easeInOut(duration: 0.05), value: dialogOpen)
            .disabled(dialogStateViewModel.isChat != .bubble || cinematic || dialogOpen)

            ImageButton(label: "magnifyingglassButton", type: .primary, size: .large) {
                NotificationCenter.default.post(name: .magnifyingButtonTapped, object: nil)
            }
            .opacity((cinematic || dialogOpen) ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.05), value: cinematic)
            .animation(.easeInOut(duration: 0.05), value: dialogOpen)
            .disabled(cinematic || dialogOpen)
        }
    }
}
