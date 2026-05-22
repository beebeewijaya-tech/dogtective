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
    // Mov System not to override the animation with `.idle`/`.moving`.
    private(set) var isPlayingOneShot: Bool = false
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
    
    // Play a one-shot sequence on the base node, then restore idle.
    func playOnce(frames: [SKTexture],
                  timePerFrame: TimeInterval? = nil,
                  scaleMultiplier: CGFloat = 1.0,
                  completion: (() -> Void)? = nil) {
        guard let sprite = baseNode as? SKSpriteNode else { completion?(); return }
        guard !frames.isEmpty else { completion?(); return }
        let perFrame = timePerFrame ?? Double(fps)


        let originalSize = sprite.size
        let originalTexture = sprite.texture
        let firstNative = frames[0].size()
        // Base scale matches existing sprite size; multiplier scales the
        // cinematic frames bigger/smaller relative to that.
        let scaleFactor = (originalSize.width / firstNative.width) * scaleMultiplier

        sprite.removeAllActions()
        isPlayingOneShot = true

        var sequence: [SKAction] = []
        for tex in frames {
            let native = tex.size()
            let target = CGSize(width: native.width * scaleFactor,
                                height: native.height * scaleFactor)
            let setFrame = SKAction.run { [weak sprite] in
                sprite?.texture = tex
                sprite?.size = target
            }
            sequence.append(setFrame)
            sequence.append(.wait(forDuration: perFrame))
        }

        sprite.run(.sequence(sequence)) { [weak self, weak sprite] in
            // Restore original texture + size before resuming idle loop.
            sprite?.texture = originalTexture
            sprite?.size = originalSize
            self?.isPlayingOneShot = false
            self?.currentState = nil
            self?.playAnimation(state: .idle)
            completion?()
        }
    }

    func playBubbleChat(isSoundEnabled: Bool) {
        guard let bubbleNode = bubbleNode, bubbleNode.isHidden else { return }
        bubbleNode.position = CGPoint(x: 0, y: 30)
        bubbleNode.isHidden = false
        bubbleNode.run(bubbleAction)
        
        AudioManager.shared.playSFX(
            fileName: "bubble_sound",
            isSoundEnabled: isSoundEnabled
        )
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
