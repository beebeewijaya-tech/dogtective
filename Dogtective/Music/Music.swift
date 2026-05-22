//
//  Music.swift
//  Dogtective
//
//  Created by Stephannie M. Linggo on 15/05/26.
//

import Foundation
import Combine
import AVFoundation

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    var player: AVAudioPlayer?
    var sfxPlayer: AVAudioPlayer?
    var typingPlayer: AVAudioPlayer?
    var campfirePlayer: AVAudioPlayer?
    var cutscenePlayer: AVAudioPlayer?
    
    private var currentMusicFile: String = "dogtective_song"
    
    private override init() {
        super.init()
    }
    
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
            
            stopAllSounds()
        }
    }
    
    func stopAllSounds() {
        sfxPlayer?.stop()
        typingPlayer?.stop()
        campfirePlayer?.stop()
        cutscenePlayer?.stop()
    }
    
    func playSFX(fileName: String, ext: String = "wav", isSoundEnabled: Bool = true) {
        // 1. Matikan jika user menonaktifkan suara di pengaturan
        guard isSoundEnabled else { return }
        
        // 2. Pindahkan inisialisasi ke Background Thread agar tidak nge-lag
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else { return }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                
                // 3. Masuk kembali ke Main Thread hanya untuk perintah play
                DispatchQueue.main.async {
                    self.sfxPlayer = player
                    self.sfxPlayer?.numberOfLoops = 0
                    
                    if fileName == "woof_sound" {
                        self.sfxPlayer?.play()
                        let oneThirdDuration = player.duration / 3.0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + oneThirdDuration) { [weak self] in
                            self?.sfxPlayer?.stop()
                        }
                    } else {
                        self.sfxPlayer?.play()
                    }
                }
            } catch {
                print("Could not find or play the SFX file: \(fileName)")
            }
        }
    }
    
    func playTypingSound(isSoundEnabled: Bool = true) {
        
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: "typewriting_sound", withExtension: "wav") else { return }
        do {
            typingPlayer = try AVAudioPlayer(contentsOf: url)
            typingPlayer?.delegate = self
            typingPlayer?.numberOfLoops = 0
            
            let startTime = typingPlayer!.duration / 3.0
            typingPlayer?.currentTime = startTime
            typingPlayer?.play()
        } catch {
            print("Gagal memutar typewriting_sound")
        }
    }
    
    func stopTypingSound() {
        typingPlayer?.stop()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === typingPlayer {
            let startTime = player.duration / 3.0
            player.currentTime = startTime
            player.play()
        }
    }
    
    func startCampfireSound(isSoundEnabled: Bool = true) {
        
        guard isSoundEnabled else { return }
        
        guard campfirePlayer == nil || campfirePlayer?.isPlaying == false else { return }
        guard let url = Bundle.main.url(forResource: "campfire_sound", withExtension: "wav") else { return }
        
        do {
            campfirePlayer = try AVAudioPlayer(contentsOf: url)
            campfirePlayer?.numberOfLoops = -1
            campfirePlayer?.play()
        } catch {
            print("Gagal memutar campfire_sound")
        }
    }
    
    func stopCampfireSound() {
        campfirePlayer?.stop()
        campfirePlayer = nil
    }
    
    func playCutsceneSound(fileName: String, loop: Int = 0) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        do {
            
            player?.stop()
            
            cutscenePlayer = try AVAudioPlayer(contentsOf: url)
            cutscenePlayer?.numberOfLoops = loop
            cutscenePlayer?.volume = 1.0
            cutscenePlayer?.play()
        } catch {
            print("Gagal memutar audio cutscene: \(fileName)")
        }
    }
    
    
    func fadeOutCutsceneAndResumeMusic(duration: TimeInterval = 1.5) {
        guard let csPlayer = cutscenePlayer, csPlayer.isPlaying else {
            
            self.playMusic(fileName: self.currentMusicFile)
            return
        }
        
        csPlayer.setVolume(0.0, fadeDuration: duration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self else { return }
            csPlayer.stop()
            self.cutscenePlayer = nil
            
            self.playMusic(fileName: self.currentMusicFile)
        }
    }
    
    func dimBackgroundMusic(isDimmed: Bool) {
        
        let targetVolume: Float = isDimmed ? 0.3 : 1.0
        player?.setVolume(targetVolume, fadeDuration: 0.3)
    }
    
    func preloadSFX(_ fileName: String) {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch { }
    }
}
