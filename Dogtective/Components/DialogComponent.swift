//
//  DialogComponent.swift
//  Dogtective
//
//  Created by Bee Wijaya on 14/05/26.
//

import GameplayKit

struct Dialog {
    var message: String
    var evidence: Bool
}

class DialogComponent: GKComponent {
    var dialog: [Dialog]
    
    init(dialog: [Dialog]) {
        self.dialog = dialog
        super.init()
    }
    
    func getDialog() -> Dialog {
        let evidence = dialog.first(where: { $0.evidence })
        if evidence != nil {
            return evidence! as Dialog
        }
        return dialog.randomElement()!
    }
    
    func removeEvidenceDialog() {
        // trigger when already talk and get evidence
        dialog.removeAll(where: { $0.evidence })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
