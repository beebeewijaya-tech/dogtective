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
    case cutscene
    case finished
}

class PageStateViewModel: ObservableObject {
    @Published var state: PageState = .home
    @Published var nextState: PageState?
    @Published var showOverlay: Bool = false // for game to cutscene
    
    func setState(_ state: PageState, nextState: PageState? = nil) {
        self.state = state
        self.nextState = nextState
    }
    
    func navigateToNextState() {
        self.state = nextState!
    }
    
    func setOverlay(isActive: Bool) {
        self.showOverlay = isActive
    }
}
