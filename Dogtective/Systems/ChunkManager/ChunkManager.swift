//
//  ChunkManager.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 13/05/26.
//

import SpriteKit

///
/// **Threading model**
/// - Background PNG decode runs on a background queue (the slow part: ~20-50ms
///   for a 1.4 MP chunk). The decoded `UIImage` is then hopped back to the main
///   queue where the `SKTexture` and `SKSpriteNode` are built and added to the
///   scene. This avoids freezing the game when the camera crosses a cell.
/// - Obstacle textures are small and come from the asset catalog (already
///   cached by SpriteKit), so they stay synchronous on the main thread.
final class ChunkManager {

    private weak var scene: GameScene?
    private let registry: ChunkRegistry
    private let activeRadius: Int

    // Background textures are not shared between chunks (each chunk has its
    // own PNG), so refcounting them would always go 0→1→0. We track them in
    // a plain dictionary instead — and skip the cache entirely.
    private var backgroundTextures: [ChunkCoord: SKTexture] = [:]
    private var backgroundNodes: [ChunkCoord: SKSpriteNode] = [:]

    // Obstacle textures (big_tree, etc.) ARE shared across chunks, so the
    // ref-counted cache is still useful here.
    private let obstacleCache: TextureRefCache

    private var contents: [ChunkCoord: ChunkContent]
    private var active: Set<ChunkCoord> = []
    private var lastCameraCoord: ChunkCoord?

    // Chunks whose background decode is in flight. Prevents double-issuing if
    // the camera bounces in/out before the async load completes.
    private var pendingBackground: Set<ChunkCoord> = []

    private let decodeQueue = DispatchQueue(
        label: "dogtective.chunk-decode",
        qos: .userInitiated,
        attributes: .concurrent
    )

    init(scene: GameScene,
         registry: ChunkRegistry,
         contents: [ChunkCoord: ChunkContent],
         activeRadius: Int = 1) {
        self.scene = scene
        self.registry = registry
        self.contents = contents
        self.activeRadius = activeRadius
        self.obstacleCache = TextureRefCache(loader: ChunkManager.makeAssetLoader())
    }

    // Call from GameScene.update(_:). Cheap when the camera hasn't crossed a cell boundary.
    func update(cameraPosition: CGPoint) {
        let coord = registry.chunkCoord(for: cameraPosition)
        if coord == lastCameraCoord { return }
        lastCameraCoord = coord

        let desired = registry.chunks(around: coord, radius: activeRadius)
        let toLoad = desired.subtracting(active)
        let toUnload = active.subtracting(desired)

        for c in toLoad { load(c) }
        for c in toUnload { unload(c) }
        active = desired
    }

    // MARK: - load / unload

    private func load(_ coord: ChunkCoord) {
        guard var content = contents[coord], let scene = scene else { return }

        // Background — async decode, attach on main.
        loadBackgroundAsync(coord: coord, fileName: content.backgroundImageFileName)

        // Obstacles — cheap, stay sync.
        for cfg in content.obstacleConfigs {
            guard let tex = obstacleCache.acquire(cfg.textureName) else { continue }
            let obs = ObstacleEntity(config: cfg, texture: tex)
            scene.register(obs)
            if let n = obs.node {
                n.position = cfg.position
                scene.addChild(n)
                content.loadedNodes.append(n)
            }
        }

        // Particles — cheap.
        for pcfg in content.particleConfigs {
            if let emitter = SKEmitterNode(fileNamed: pcfg.fileName) {
                emitter.position = pcfg.position
                if let s = pcfg.particleSize { emitter.particleSize = s }
                scene.addChild(emitter)
                content.loadedNodes.append(emitter)
            }
        }

        contents[coord] = content
    }

    private func loadBackgroundAsync(coord: ChunkCoord, fileName: String) {
        // Already loaded (e.g. chunk re-entered the active set before its texture was dropped)?
        if let existing = backgroundTextures[coord], backgroundNodes[coord] == nil {
            attachBackgroundNode(coord: coord, texture: existing)
            return
        }
        if backgroundNodes[coord] != nil { return }      // already on screen
        if pendingBackground.contains(coord) { return }  // decode already in flight

        pendingBackground.insert(coord)
        decodeQueue.async { [weak self] in
            guard let path = Bundle.main.path(forResource: fileName, ofType: nil),
                  let image = UIImage(contentsOfFile: path) else {
                DispatchQueue.main.async { self?.pendingBackground.remove(coord) }
                return
            }
            // Force-decode the bitmap on this background queue (UIImage is lazy
            // otherwise — and that lazy decode would happen on the main thread
            // the first time the texture is drawn, reintroducing the hitch).
            _ = image.cgImage?.dataProvider?.data

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.pendingBackground.remove(coord)
                // Camera may have already moved away by the time we got here.
                guard self.active.contains(coord) else { return }
                let texture = SKTexture(image: image)
                // Nearest filtering avoids bilinear bleed past the texture edge,
                // which is what causes visible seams between adjacent chunks.
                texture.filteringMode = .nearest
                self.backgroundTextures[coord] = texture
                self.attachBackgroundNode(coord: coord, texture: texture)
            }
        }
    }

    private func attachBackgroundNode(coord: ChunkCoord, texture: SKTexture) {
        guard let scene = scene, backgroundNodes[coord] == nil else { return }
        let node = SKSpriteNode(texture: texture)
        // Integer-snap size to kill sub-pixel seams between chunks.
        // Nearest filtering (set on texture) handles the bilinear-bleed case.
        let cs = registry.chunkSize
        node.size = CGSize(width: cs.width.rounded(),
                           height: cs.height.rounded())
        let c = registry.chunkCenter(for: coord)
        node.position = CGPoint(x: c.x.rounded(), y: c.y.rounded())
        node.zPosition = -10000
        scene.addChild(node)
        backgroundNodes[coord] = node

        if var content = contents[coord] {
            content.loadedNodes.append(node)
            contents[coord] = content
        }
    }

    private func unload(_ coord: ChunkCoord) {
        guard var content = contents[coord] else { return }
        for node in content.loadedNodes { node.removeFromParent() }
        content.loadedNodes.removeAll()
        contents[coord] = content

        backgroundNodes.removeValue(forKey: coord)
        backgroundTextures.removeValue(forKey: coord)

        for cfg in content.obstacleConfigs { obstacleCache.release(cfg.textureName) }
        // Particle emitters own their own textures internally — nothing to release here.
    }

    // MARK: - loaders

    private static func makeAssetLoader() -> TextureRefCache.Loader {
        return { name in SKTexture(imageNamed: name) }
    }
}
