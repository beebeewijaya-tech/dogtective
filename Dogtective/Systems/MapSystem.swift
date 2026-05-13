//
//  LayoutSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit


// MARK: - Map System
// will contains the setup about the map, map position
extension GameScene {
    func addEntity(_ entity: BaseEntity, position: CGPoint?, cam: SKCameraNode? = nil) {
        guard let node = entity.node else { return }
        if position != nil {
            // if position provided
            node.position = position!
        }
        if cam != nil {
            cam?.addChild(node)
        } else {
            addChild(node)
        }
    }
    
    func setupPlayer() {
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.spriteNode else { return }
        register(playerEntity)
        addEntity(playerEntity, position: CGPoint(x: -769, y: 34))

        // Player physics body
        let bodyWidth = node.size.width * 0.4
        let bodyHeight = node.size.height * 0.2
        let bodyOffset = CGPoint(x: 0, y: -node.size.height * 0.35)
        node.applyDynamicBody(
            shape: .rectangle(CGSize(width: bodyWidth, height: bodyHeight)),
            offset: bodyOffset,
            collidesWith: PhysicsCategory.obstacle | PhysicsCategory.npc
        )
        
        playerEntity.animation?.playAnimation(state: .idle)
        cameraFollowPlayer()
    }
    
    func setupJoystick() {
        guard let joystickSystem = joystickSystem else { return }
        joystickSystem.setupJoystick()
    }
        
    func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "map_district")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.size = CGSize(width: 3634, height: 1449)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -10000
        addChild(background)
        
        // TODO: fix and think to render this somewhere else
        setupFire()
        setupFoodStallSmoke()
        setupLampLight()
        setupObstacles()
    }

    func setupObstacles() {
        let configs: [ObstacleConfig] = [
            .bigTree(at: CGPoint(x: -445, y: 285)),
            .bigTree(at: CGPoint(x: -876, y: -419)),
        ]
        for cfg in configs {
            let obs = ObstacleEntity(config: cfg)
            register(obs)
            addEntity(obs, position: cfg.position)
        }
    }
    
    func setupFire() {
        if let fire = SKEmitterNode(fileNamed: "BonFire") {
            fire.position = bonfirePosition
            fire.particleSize = CGSize(width: 100, height: 100)
            addChild(fire)
        }
    }
    
    
    func setupFoodStallSmoke() {
        for pos in self.foodStallPosition {
            if let smoke = SKEmitterNode(fileNamed: "FoodStallSmoke") {
                smoke.position = pos
                addChild(smoke)
            }
        }
    }
    
    func setupLampLight() {
        for pos in self.lampLightPosition {
            if let lamp = SKEmitterNode(fileNamed: "Lamp") {
                lamp.position = pos
                addChild(lamp)
            }
        }
    }
}
