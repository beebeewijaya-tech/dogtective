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
    var sfxPlayer: AVAudioPlayer?
    
    func playMusic(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
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
    
    func playSFX(fileName: String, ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else { return }
        
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.numberOfLoops = 0 
            sfxPlayer?.play()
        } catch {
            print("Could not find or play the SFX file: \(fileName)")
        }
    }
}

