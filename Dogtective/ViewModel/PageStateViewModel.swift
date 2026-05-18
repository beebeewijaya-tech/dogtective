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
}

class PageStateViewModel: ObservableObject {
    @Published var state: PageState = .home
    @Published var nextState: PageState?
    
    func setState(_ state: PageState, nextState: PageState? = nil) {
        self.state = state
        self.nextState = nextState
    }
    
    func navigateToNextState() {
        self.state = nextState!
    }
}
