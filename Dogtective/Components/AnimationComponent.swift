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
    
    
    init(idleFrames: [SKTexture], walkingFrames: [SKTexture]) {
        self.idleFrames = idleFrames
        self.walkingFrames = walkingFrames
        super.init()
    }
    
    var baseNode: SKNode? {
        entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKNode
    }
    
    func playAnimation(state: PlayerState) {
        guard let node = baseNode else { return }
        guard state != currentState else { return }
        currentState = state
        
        let frames = state == .idle ? idleFrames : walkingFrames
        node.removeAllActions()
        let animate = SKAction.animate(with: frames, timePerFrame: fps)
        node.run(.repeatForever(animate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
