//
//  AnimationComponent.swift
//  Dogtective
//
//  Created by Bee Wijaya on 12/05/26.
//

import GameplayKit

class AnimationComponent: GKComponent {
    var idleFrames: [SKTexture]
    var walkingFrames: [SKTexture]
    var currentState: PlayerState?
    let fps: CGFloat = 1/30
    var bubbleFrames: [SKTexture]
    private lazy var bubbleAction: SKAction = {
        .repeatForever(.animate(with: bubbleFrames, timePerFrame: fps))
    }()
    
    init(idleFrames: [SKTexture] = [], walkingFrames: [SKTexture] = [], bubbleFrames: [SKTexture] = []) {
        self.idleFrames = idleFrames
        self.walkingFrames = walkingFrames
        self.bubbleFrames = bubbleFrames
        super.init()
    }
    
    var baseNode: SKNode? {
        entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKNode
    }
    
    var bubbleNode: SKSpriteNode? {
        baseNode?.childNode(withName: "bubble") as? SKSpriteNode
    }
    
    func playAnimation(state: PlayerState) {
        guard let node = baseNode else { return }
        guard state != currentState else { return }
        currentState = state
        
        let frames: [SKTexture]
        switch state {
            case .idle:
                frames = self.idleFrames
            case .moving:
                frames = self.walkingFrames
            default:
                frames = self.idleFrames
        }
        node.removeAllActions()
        let animate = SKAction.animate(with: frames, timePerFrame: fps)
        node.run(.repeatForever(animate))
    }
    
    func playBubbleChat() {
        guard let bubbleNode, bubbleNode.isHidden else { return }
        bubbleNode.position = CGPoint(x: 0, y: 30)
        bubbleNode.isHidden = false
        bubbleNode.run(bubbleAction)
    }
    
    func removeBubbleChat() {
        guard let bubbleNode = bubbleNode else { return }
        bubbleNode.removeAllActions()
        bubbleNode.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
