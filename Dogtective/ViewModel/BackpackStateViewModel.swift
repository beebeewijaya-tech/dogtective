//
//  BackpackStateViewModel.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 16/05/26.
//

import SwiftUI
import Combine

class BackpackStateViewModel: ObservableObject {
    @Published var collectedKeys: Set<String> = []
    @Published var hasUnseen: Bool = false

    // Add a backpack item key (e.g. "corn"). Flips icon to `<key>_on`
    func collect(_ key: String?) {
        guard let key = key, !key.isEmpty else { return }
        let inserted = collectedKeys.insert(key).inserted
        if inserted { hasUnseen = true }
    }

    func markSeen() {
        hasUnseen = false
    }
}
