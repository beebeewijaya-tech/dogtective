//
//  MovementSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit
import GameplayKit

class MovementSystem: GKComponentSystem<MovementComponent> {
    var joystickEntity: JoystickEntity?
    var playerEntity: PlayerEntity?

    private var footsteps: SKEmitterNode?
    private var footstepsBirthRate: CGFloat = 0

    init(joystickEntity: JoystickEntity?, playerEntity: PlayerEntity?) {
        self.joystickEntity = joystickEntity
        self.playerEntity = playerEntity
        super.init(componentClass: MovementComponent.self)
    }

    private func setupFootsteps(on playerNode: SKNode) {
        guard footsteps == nil, let emitter = SKEmitterNode(fileNamed: "Footstep") else { return }
        footstepsBirthRate = max(emitter.particleBirthRate, 2.5)
        emitter.particleBirthRate = 0
        emitter.particleScale = 0.24
        emitter.position = CGPoint(x: 0, y: -playerNode.frame.height / 2 + 4)
        guard let world = playerNode.parent else { return }
        
        let layerName = "footstepLayer"
        let layer = world.childNode(withName: layerName) ?? {
            let node = SKNode()
            node.name = layerName
            node.zPosition = -9000
            world.addChild(node)
            return node
        }()

        emitter.zPosition = 0
        emitter.targetNode = layer
        playerNode.addChild(emitter)
        footsteps = emitter
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerEntity = playerEntity else { return }
        guard let playerNode = playerEntity.spriteNode else { return }
        guard let joystickEntity = joystickEntity else { return }

        setupFootsteps(on: playerNode)

        // Locked during cutscene-like flows
        if playerEntity.movement?.isLocked == true {
            playerEntity.movement?.velocity = .zero
            playerNode.physicsBody?.velocity = .zero
            footsteps?.particleBirthRate = 0
            // Only force idle if a one-shot anim isn't already playing
            if playerEntity.animation?.isPlayingOneShot != true {
                playerEntity.animation?.playAnimation(state: .idle)
            }
            return
        }

        let dx = joystickEntity.knob.position.x - joystickEntity.base.position.x
        let dy = joystickEntity.knob.position.y - joystickEntity.base.position.y

        playerEntity.movement?.velocity = CGVector(dx: dx, dy: dy)
        if dx != 0 || dy != 0 {
            playerNode.xScale = dx > 0 ? 1 : -1
            playerEntity.animation?.playAnimation(state: .moving)
            if let footsteps = footsteps {
                let angle = atan2(dy, dx)

                footsteps.xScale = playerNode.xScale
                footsteps.particleRotation = angle - .pi / 2
                footsteps.emissionAngle = angle
                footsteps.particleBirthRate = footstepsBirthRate
            }
        } else {
            playerEntity.animation?.playAnimation(state: .idle)
            footsteps?.particleBirthRate = 0
        }

        playerEntity.update(deltaTime: seconds) // will run the movement
    }
}


// MARK: - Movement System
// implementing the movement of the player
extension GameScene {
    func setMapPosition() {
        guard let playerEntity = playerEntity else { return }
        guard let playerNode = playerEntity.node else { return }

        let next: MinimapState
        if playerNode.position.x > 458 && playerNode.position.y > 159 {
            next = .park
        } else if playerNode.position.x > 458 {
            next = .central
        } else if playerNode.position.y > 159 {
            next = .house
        } else {
            next = .police
        }

        if minimapStateViewModel?.state != next {
            minimapStateViewModel?.setState(next)
        }
    }
}
