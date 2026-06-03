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
            Dialog(message: "There's a patch of dirt near the police station that keeps getting disturbed. Strange.", evidence: false),
            Dialog(message: "That Billy fella sure eats a lot of corn for someone who's supposedly not nervous.", evidence: false),
            Dialog(message: "My nose has been twitching near the north-west side all week. Don't know why.", evidence: false),
            Dialog(message: "This doesn't feel random. Someone planned this.", evidence: false),
            Dialog(message: "That corn stall area smells like more than just corn lately.", evidence: false)
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
    
    static func timmyDialogs() -> [Dialog] {
        return [
            Dialog(message: "There's something fluffy stuck near the house around post office. I tried to reach it but I'm too small.", evidence: false),
            Dialog(message: "This doesn't feel random. Someone planned this.", evidence: false),
            Dialog(message: "Maybe mrs. Milo is doing gardening at her house", evidence: false),
            Dialog(message: "I'm not supposed to be out late but... I saw someone carrying a bag to the trash", evidence: false)
        ]
    }
}
