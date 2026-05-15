//
//  Music.swift
//  Dogtective
//
//  Created by Stephannie M. Linggo on 15/05/26.
//

import Foundation
import Combine
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    var player: AVAudioPlayer?

    func playMusic(fileName: String) {
        guard let url = Bundle.main.url(forResource: "dogtective_song", withExtension: "wav") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.play()
        } catch {
            print("Could not find or play the audio file.")
        }
    }

    func stopMusic() {
        player?.stop()
    }
    
    func toggleMusic(isOn: Bool) {
        if isOn {
            player?.play()
        } else {
            player?.pause()
        }
    }
}

