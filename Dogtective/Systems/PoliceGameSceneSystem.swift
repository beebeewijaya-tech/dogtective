//
//  PoliceGameSceneSystem.swift
//  Dogtective
//
//  Created by Michael David Sin on 11/05/26.
//

import SpriteKit

// MARK: - Police Game Systems
extension PoliceGameScene {
    // FIXME: let's refactor this whole
    // TODO: Bee's urgent do the fix
    
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
    
    func setupPolice() {
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.spriteNode else { return }

        police1 = PoliceEntity(type: 1)
        if let p1 = police1 {
            p1.position = CGPoint(x: 322.0, y: 184.3333282470703)
            p1.zPosition = 1
            p1.size = node.size
            addChild(p1)
        }
        
        police2 = PoliceEntity(type: 2)
        if let p2 = police2 {
            
            p2.position = CGPoint(x: 375.3333435058594, y: 228.0)
            p2.zPosition = 1

            p2.size = node.size
            
            addChild(p2)
        }
    }
    
    func setupJoystick() {
        guard let entity = joystickEntity else { return }
        
        entity.position = CGPoint(x: size.width / 2, y: size.height / 2)
        entity.zPosition = 100
        
        if entity.parent == nil {
            addChild(entity)
        }
    }
    
    func handleTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first, let joy = joystickEntity else { return }
        
        let locationInScene = touch.location(in: self)
        
        let locInJoy = touch.location(in: joy)
        
        if joy.base.contains(locInJoy) {
            joy.joystickUI = touch
        }
    }
    
    func setupNPCs() {
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.spriteNode else { return }
        
        npc6 = NPCEntity(id: 6)
        if let n6 = npc6 {
            n6.position = CGPoint(x: 424.3333435058594, y: 119.3333511352539)
            n6.size = node.size
            n6.zPosition = 1
            addChild(n6)
        }

        npc7 = NPCEntity(id: 7)
        if let n7 = npc7 {
            n7.position = CGPoint(x: 457.6666564941406, y: 61.33332824707031)
            n7.size = node.size
            n7.zPosition = 1
            addChild(n7)
        }

        npc10 = NPCEntity(id: 10)
        if let n10 = npc10 {
            n10.position = CGPoint(x: 611.6666870117188, y: 75.66665649414062)
            n10.size = node.size
            n10.zPosition = 1
            addChild(n10)
        }
    }
     func apply(to nodes: [SKNode], offset: CGFloat = 0) {
           for node in nodes {
               node.zPosition = -sortY(for: node) + offset
           }
       }

       // Sort by visual base (feet) so anchor differences don't break ordering.
       func sortY(for node: SKNode) -> CGFloat {
           if let sprite = node as? SKSpriteNode {
               return sprite.position.y - sprite.size.height * sprite.anchorPoint.y
           }
           return node.position.y
       }
    
    func applyYSort() {
        var nodes: [SKNode] = []
        if let p = playerEntity, let node = p.spriteNode { nodes.append(node) }
        if let p1 = police1 { nodes.append(p1) }
        if let p2 = police2 { nodes.append(p2) }
        if let n6 = npc6 { nodes.append(n6) }
        if let n7 = npc7 { nodes.append(n7) }
        if let n10 = npc10 { nodes.append(n10) }
        
        apply(to: nodes)
    }
    
    func handleMove(_ touches: Set<UITouch>) {
        
        guard let joy = joystickEntity, let touch = joy.joystickUI as? UITouch else { return }
        
        let loc = touch.location(in: joy)
        
        let dx = loc.x - joy.base.position.x
        let dy = loc.y - joy.base.position.y
        let dist = hypot(dx, dy)
        
        if dist > joy.maxRadius {
            joy.knob.position = CGPoint(
                x: joy.base.position.x + (dx/dist)*joy.maxRadius,
                y: joy.base.position.y + (dy/dist)*joy.maxRadius
            )
        } else {
            joy.knob.position = loc
        }
    }
    
    func handleEnd() {
        joystickEntity?.joystickUI = nil
        joystickEntity?.knob.position = joystickEntity?.base.position ?? .zero
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
        
        if let p1 = police1 { applyObstacleToNode(p1) }
        if let p2 = police2 { applyObstacleToNode(p2) }
        if let n6 = npc6 { applyObstacleToNode(n6) }
        if let n7 = npc7 { applyObstacleToNode(n7) }
        if let n10 = npc10 { applyObstacleToNode(n10) }
    }

    private func applyObstacleToNode(_ node: SKNode) {
        node.applyStaticBody(
            shape: .rectangle(CGSize(width: 40, height: 40)),
            offset: CGPoint(x: 0, y: -20), 
            category: PhysicsCategory.obstacle,
            collidesWith: PhysicsCategory.player
        )
    }
}
