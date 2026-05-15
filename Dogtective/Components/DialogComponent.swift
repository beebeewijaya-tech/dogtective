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
    let dialog: [Dialog]
    
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
