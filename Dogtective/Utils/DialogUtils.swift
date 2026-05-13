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
            Dialog(message: "The stars told me you would arrive today.", evidence: false),
            Dialog(message: "Move along unless you're buying a fresh bones.", evidence: false),
            Dialog(message: "The city winds always bring trouble our way.", evidence: false),
            Dialog(message: "Bones missing don't happen by accident, my friend", evidence: false),
            Dialog(message: "My advice? Don't say a single word without me", evidence: false),
        ]
    }
    
    static func dummyPoliceDialogs() -> [Dialog] {
        return [
            Dialog(message: "Hello, Professor. Sorry to pull you away from campus, but we need your expertise on this occult symbol.", evidence: false),
            Dialog(message: "Step back, sir, oh, wait, sorry Detective. Didn't recognize you without your badge out.", evidence: false),
            Dialog(message: "Thanks for coming so fast, Professor. The victim was one of your faculty members", evidence: false)
        ]
    }
}
