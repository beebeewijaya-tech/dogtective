//
//  PlayerNode.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit

enum PlayerState {
    case idle, moving
}

struct PlayerInfo {
    var texture: SKTexture?
    var coordinates: CGPoint?
    var state: PlayerState?
}


class PlayerEntity: SKSpriteNode {
    var playerInfo: PlayerInfo?
    var playerIdleAtlas = SKTextureAtlas(named: "player_idle")
    var playerIdleFrames: [SKTexture] = []
    
    var playerMoveAtlas = SKTextureAtlas(named: "player_walking")
    var playerMoveFrames: [SKTexture] = []
    
    var playerSpeed: CGFloat = 0.05 // TODO: tune it
    
    
    init(playerInfo: PlayerInfo?) {
        self.playerInfo = playerInfo
        let firstFrame = playerIdleAtlas.textureNamed("mrbones-idle_00") // for first render or default
        
        super.init(
            texture: playerInfo?.texture ?? firstFrame,
            color: .clear,
            size: .zero
        )
        
        prepareMovingFrames()
        prepareIdleFrames()
    }
    
    // MARK: - Idle animation
    func prepareIdleFrames() {
        // player idle injecting preparation frame
        
        for i in 1...62 {
            playerIdleFrames.append(playerIdleAtlas.textureNamed(String(format: "mrbones-idle_%02d", i)))
        }
    }
    func idlePlayerState() {
        // run animation after frames injected
        playerInfo?.state = .idle
        animatePlayer(frames: playerIdleFrames)
    }
    
    // MARK: - Movement animation
    func prepareMovingFrames() {
        // player moving injecting preparation frame
        
        for i in 1...23 {
            playerMoveFrames.append(playerMoveAtlas.textureNamed(String(format: "mrbones-walking_%02d", i)))
        }
    }
    func movingPlayerState() {
        // moving animation after frame injected
        playerInfo?.state = .moving
        animatePlayer(frames: playerMoveFrames, timePerFrame: 0.0417)
    }

    
    func animatePlayer(frames: [SKTexture], timePerFrame: TimeInterval = 0.01) {
        // animatePlayer will run animation given the frames
        self.removeAllActions()
        let animate = SKAction.animate(with: frames, timePerFrame: timePerFrame)
        self.run(SKAction.repeatForever(animate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
