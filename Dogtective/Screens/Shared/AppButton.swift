//
//  AppButton.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

enum ButtonSize {
    case small, medium, large
    
    var labelSize: CGFloat {
        switch self {
        case .small: return 30
        case .medium: return 40
        case .large: return 50
        }
    }
    
    var backgroundSize: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 50
        case .large: return 60
        }
    }
    
    var outerSize: CGFloat {
        switch self {
        case .small: return 50
        case .medium: return 70
        case .large: return 90
        }
    }
}


struct AppButton: View {
    // TODO: implement button components
    var body: some View {
        Text("Hello, World!")
    }
}

struct ImageButton: View {
    var label: String
    var type: ColorState
    var size: ButtonSize
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(label)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
        }

    }
}
