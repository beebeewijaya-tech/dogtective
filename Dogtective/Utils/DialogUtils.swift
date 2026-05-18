//
//  DialogUtils.swift
//  Dogtective
//
//  Created by Bee Wijaya on 14/05/26.
//

import SwiftUI

// Static class
struct DialogUtils {
    static func dummyDialogs() -> [Dialog] {
        return [
            Dialog(message: "The city winds always bring trouble our way.", evidence: false),
            Dialog(message: "Bones missing don't happen by accident, my friend.", evidence: false),
        ]
    }
    
    static func dummyPoliceDialogs() -> [Dialog] {
        return [
            Dialog(message: "Hey there, detective.", evidence: false),
            Dialog(message: "Lovely day for a walk.", evidence: false),
            Dialog(message: "Stay safe out there.", evidence: false),
        ]
    }
}
