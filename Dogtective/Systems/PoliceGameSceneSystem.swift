//
//  PoliceGameSceneSystem.swift
//  Dogtective
//
//  Created by Michael David Sin on 11/05/26.
//

import SpriteKit

// MARK: - Police Game Systems
// TODO: Bee will refactor this afterwards
extension PoliceGameScene {
    func addEntity(_ entity: BaseEntity, position: CGPoint?) {
        guard let node = entity.node else { return }
        if position != nil {
            // if position provided
            node.position = position!
        }
        addChild(node)
    }
    
    func setupPlayer() {
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.spriteNode else { return }
        addEntity(playerEntity, position: CGPoint(x: size.width / 2, y: size.height / 2))

        // Player physics body
        let bodyWidth = node.size.width * 0.4
        let bodyHeight = node.size.height * 0.2
        let bodyOffset = CGPoint(x: 0, y: -node.size.height * 0.35)
        node.applyDynamicBody(
            shape: .rectangle(CGSize(width: bodyWidth, height: bodyHeight)),
            offset: bodyOffset
        )
        
        playerEntity.animation?.playAnimation(state: .idle)
    }
    
    func setupNPCs() {
        for npc in npcs {
            guard let node = npc.spriteNode else { continue }
            addEntity(npc, position: npc.position)
            
            let bodyWidth = node.size.width * 0.4
            let bodyHeight = node.size.height * 0.2
            let bodyOffset = CGPoint(x: 0, y: -node.size.height * 0.35)
            node.applyStaticBody(
                shape: .rectangle(CGSize(width: bodyWidth, height: bodyHeight)),
                offset: bodyOffset
            )
            
            npc.animation?.playAnimation(state: .idle)
        }
    }
    
    func setupCollisions() {
        let wallLeft = SKNode()
        wallLeft.position = CGPoint(x: 140.0, y: 250)
        wallLeft.applyStaticBody(shape: .rectangle(CGSize(width: 40, height: 1000)))
        addChild(wallLeft)
        
        let wallRight = SKNode()
        wallRight.position = CGPoint(x: 735.0, y: 250)
        wallRight.applyStaticBody(shape: .rectangle(CGSize(width: 40, height: 1000)))
        addChild(wallRight)

        let wallTop = SKNode()
        
        wallTop.position = CGPoint(x: 437.5, y: 290)

        let horizontalWallSize = CGSize(width: 1000, height: 40)
        
        wallTop.applyStaticBody(
            shape: .rectangle(horizontalWallSize),
            category: PhysicsCategory.obstacle,
            collidesWith: PhysicsCategory.player
        )
        addChild(wallTop)
        
        let wallBottom = SKNode()
        wallBottom.position = CGPoint(x: 437.5, y: -10)
        
        wallBottom.applyStaticBody(
            shape: .rectangle(horizontalWallSize),
            category: PhysicsCategory.obstacle,
            collidesWith: PhysicsCategory.player
        )
        addChild(wallBottom)
    }
    
    func setupJoystick() {
        guard let joystickSystem = joystickSystem else { return }
        joystickSystem.setupJoystick()
    }
}
