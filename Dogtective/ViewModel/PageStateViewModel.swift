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
}

class PageStateViewModel: ObservableObject {
    @Published var state: PageState = .home
    
    func setState(_ state: PageState) {
        self.state = state
    }
}
