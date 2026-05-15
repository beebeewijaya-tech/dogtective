//
//  PageStateViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import Combine
import SwiftUI

enum PageState {
    case home
    case game
    case level
    case loading
}

class PageStateViewModel: ObservableObject {
    @Published var state: PageState = .game
    @Published var selectedLevel: Int = 1
    
    func setState(_ state: PageState) {
        self.state = state
    }
}
