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
        
    func setState(_ state: DialogState) {
        isChat = state
    }
    
    func getChat() -> Bool {
        return isChat == .chat || isChat == .bubble
    }
}
