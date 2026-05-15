//
//  DialogStateViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 14/05/26.
//

import SwiftUI
import Combine

enum DialogState {
    case chat
    case idle
    case bubble
}

class DialogStateViewModel: ObservableObject {
    @Published var isChat: DialogState = .idle
    @Published var npc: String?
    @Published var dialog: Dialog?
        
    func setState(_ state: DialogState) {
        guard isChat != state else { return }
        isChat = state
    }
    
    func setDialog(dialog: Dialog, npc: String) {
        self.dialog = dialog
        self.npc = npc
    }
    
    func resetDialog() {
        self.dialog = nil
        self.npc = nil
    }
}
