//
//  Haptics.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 13/05/26.
//

import SwiftUI
import UIKit

enum Haptics {
    static var isEnabled: Bool = true

    static func tap() {
        guard isEnabled else { return }
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
}

struct HapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Haptics.tap() }
            }
    }
}
