//
//  MinimapStateViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 07/05/26.
//

import Combine

enum MinimapState {
    case house,
         police,
         park,
         central
    
    var minimapState: String {
        switch self {
        case .house:
            return "minimap_house"
        case .police:
            return "minimap_police"
        case .park:
            return "minimap_park"
        case .central:
            return "minimap_central"
        }
    }
}

class MinimapStateViewModel: ObservableObject {
    @Published var state: MinimapState = .police
    
    func setState(_ state: MinimapState) {
        guard self.state != state else { return }
        self.state = state
    }
}
