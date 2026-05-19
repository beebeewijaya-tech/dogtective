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
    
    static func billyDialogs() -> [Dialog] {
        return [
            Dialog(message: "I hope you soon find the culprit", evidence: false),
            Dialog(message: "This corn taste so good", evidence: false),
            Dialog(message: "Why that kid always playing there?", evidence: false),
        ]
    }
    
    static func chichiDialogs() -> [Dialog] {
        return [
            Dialog(message: "Hachoooo! I can't believe they suspect me", evidence: false),
            Dialog(message: "You believe me right detective?", evidence: false),
            Dialog(message: "I hope the truth will prevail", evidence: false),
        ]
    }
    
    static func billyNewDialog() -> [Dialog] {
        return [
            Dialog(message: "W-Why are you looking at me like that? I didn’t do anything!", evidence: false),
            Dialog(message: "You’re wasting your time! Go question someone else already!", evidence: false),
            Dialog(message: "Those clues don’t prove anything… right? They could belong to anyone!", evidence: false),
            Dialog(message: "I only wanted to scare them a little… I didn’t think things would go this far…", evidence: false),
            Dialog(message: "No… no, this can’t be happening. You’re not seriously blaming me, are you?", evidence: false),
        ]
    }
}
