//
//  PoliceGameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit

class PoliceGameScene: SKScene {

    var playerEntity: PlayerEntity?
    var joystickEntity: JoystickEntity?
    var bg = SKSpriteNode(imageNamed: "map_police")
    var minimapStateViewModel: MinimapStateViewModel?
    
    var police1: PoliceEntity?
    var police2: PoliceEntity?
    
    var npc6: NPCEntity?
    var npc7: NPCEntity?
    var npc10: NPCEntity?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = .zero
        
        playerEntity = PlayerEntity(playerInfo: PlayerInfo())
        joystickEntity = JoystickEntity(sceneSize: size)
        
        setupBackground()
        setupPlayer()
        setupCollisions()
        setupJoystick()
        setupNPCs()
        setupPolice()
    }
    
    func setupBackground() {
        let scale = min(size.width/bg.size.width, size.height/bg.size.height)
        bg.setScale(scale)
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -1
        addChild(bg)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleMove(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleEnd()
    }
    
    override func update(_ currentTime: TimeInterval) {
        movePlayer()
    }
}


class PoliceEntity: SKSpriteNode {
    var policeIdleAtlas: SKTextureAtlas
    var policeIdleFrames: [SKTexture] = []
    var policeType: Int
    
    init(type: Int) {
        self.policeType = type
        let atlasName = "police_\(type)_idle"
        self.policeIdleAtlas = SKTextureAtlas(named: atlasName)

        let firstFrameName = "police\(type)-idle_00"
        let firstFrame = policeIdleAtlas.textureNamed(firstFrameName)
        
        super.init(texture: firstFrame, color: .clear, size: firstFrame.size())
        
        prepareIdleFrames()
        playIdleAnimation()
    }
    
    func prepareIdleFrames() {

        for i in 0...59 {

            let textureName = String(format: "police\(policeType)-idle_%02d", i)
            let texture = policeIdleAtlas.textureNamed(textureName)
            policeIdleFrames.append(texture)
        }
    }
    
    func playIdleAnimation() {
        self.removeAllActions()
        let animate = SKAction.animate(with: policeIdleFrames, timePerFrame: 1.0/30.0)
        self.run(SKAction.repeatForever(animate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NPCEntity: SKSpriteNode {
    var npcAtlas: SKTextureAtlas
    var npcFrames: [SKTexture] = []
    var npcID: Int
    
    init(id: Int) {
        self.npcID = id
        self.npcAtlas = SKTextureAtlas(named: "npc_\(id)_idle")

        let firstFrameName = "npc\(id)-idle_00"
        let firstFrame = npcAtlas.textureNamed(firstFrameName)
        
        super.init(texture: firstFrame, color: .clear, size: firstFrame.size())
        
        prepareAnimation()
        playAnimation()
    }
    
    func prepareAnimation() {
        
        for i in 0...59 {
            let textureName = String(format: "npc\(npcID)-idle_%02d", i)
            npcFrames.append(npcAtlas.textureNamed(textureName))
        }
    }
    
    func playAnimation() {
        self.removeAllActions()
        let animate = SKAction.animate(with: npcFrames, timePerFrame: 1.0/30.0)
        self.run(SKAction.repeatForever(animate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
