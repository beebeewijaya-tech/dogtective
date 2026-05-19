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
    let registry: ChunkRegistry
    private let activeRadius: Int

    // Background textures are not shared between chunks (each chunk has its
    // own PNG), so refcounting them would always go 0→1→0. We track them in
    // a plain dictionary instead — and skip the cache entirely.
    private var backgroundTextures: [ChunkCoord: SKTexture] = [:]
    private var backgroundNodes: [ChunkCoord: SKSpriteNode] = [:]

    // Obstacle textures (big_tree, etc.) ARE shared across chunks, so the
    // ref-counted cache is still useful here.
    private let obstacleCache: TextureRefCache

    // Obstacles can be bucketed into multiple chunks (when their visual rect
    // spans chunk boundaries), so we dedupe instantiation by config id and
    // refcount across active chunks.
    private struct LoadedObstacle {
        let entity: ObstacleEntity
        var refcount: Int
        var textureName: String
        let config: ObstacleConfig
    }
    private var loadedObstacles: [Int: LoadedObstacle] = [:]

    private var contents: [ChunkCoord: ChunkContent]
    private var active: Set<ChunkCoord> = []
    private var lastCameraCoord: ChunkCoord?

    // Chunks whose background decode is in flight. Prevents double-issuing if
    // the camera bounces in/out before the async load completes.
    private var pendingBackground: Set<ChunkCoord> = []

    // Burn-mode swaps a fixed set of chunks (5,6,7,13,14,15) to their `_burn`
    // PNG variants. Toggled externally when evidence collected reaches threshold.
    // Per-coord generation lets us invalidate in-flight decodes when the mode
    // flips mid-load — otherwise the old-filename decode would race the reload
    // and attach a stale background.
    private var burnActive: Bool = false
    private let burnIndices: Set<Int> = [5, 6, 7, 13, 14, 15]
    private var loadGeneration: [ChunkCoord: Int] = [:]

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

    // MARK: - burn mode
    // Flip burn-variant rendering for chunks in `burnIndices`. Reloads
    func setBurned(_ active: Bool) {
        guard burnActive != active else { return }
        burnActive = active

        for coord in self.active where burnIndices.contains(chunkIndex(coord)) {
            guard let content = contents[coord] else { continue }
            // Tear down current background (node + texture). Bump generation
            if let node = backgroundNodes.removeValue(forKey: coord) {
                node.removeFromParent()
                if var c = contents[coord] {
                    c.loadedNodes.removeAll { $0 === node }
                    contents[coord] = c
                }
            }
            backgroundTextures.removeValue(forKey: coord)
            pendingBackground.remove(coord)
            loadGeneration[coord, default: 0] += 1

            loadBackgroundAsync(coord: coord, fileName: currentBackgroundFileName(for: coord, base: content.backgroundImageFileName))
        }

        // Obstacle texture swap (park trees, log_2 etc.). Walk all loaded
        for (id, loaded) in loadedObstacles {
            guard let burnName = loaded.config.burnTextureName else { continue }
            let desiredName = active ? burnName : loaded.config.textureName
            guard desiredName != loaded.textureName else { continue }
            guard let newTex = obstacleCache.acquire(desiredName) else { continue }
            loaded.entity.reskin(with: newTex, config: loaded.config)
            obstacleCache.release(loaded.textureName)
            var updated = loaded
            updated.textureName = desiredName
            loadedObstacles[id] = updated
        }

        // burnOnly obstacles: spawn into currently active chunks when flipping
        // on, tear down when flipping off.
        // unburnedOnly obstacles do the inverse: tear down on flip-on, respawn on flip-off.
        guard let scene = scene else { return }
        if active {
            var spawnedIds: Set<Int> = []
            for coord in self.active {
                guard let content = contents[coord] else { continue }
                for cfg in content.obstacleConfigs where cfg.burnOnly {
                    if loadedObstacles[cfg.id] != nil {
                        // Already spawned via another bucketed chunk this pass.
                        if spawnedIds.contains(cfg.id) {
                            loadedObstacles[cfg.id]?.refcount += 1
                        }
                        continue
                    }
                    spawnObstacle(cfg, in: scene)
                    spawnedIds.insert(cfg.id)
                }
            }
            for (id, loaded) in loadedObstacles where loaded.config.unburnedOnly {
                loaded.entity.node?.removeFromParent()
                obstacleCache.release(loaded.textureName)
                loadedObstacles.removeValue(forKey: id)
            }
        } else {
            for (id, loaded) in loadedObstacles where loaded.config.burnOnly {
                loaded.entity.node?.removeFromParent()
                obstacleCache.release(loaded.textureName)
                loadedObstacles.removeValue(forKey: id)
            }
            var spawnedIds: Set<Int> = []
            for coord in self.active {
                guard let content = contents[coord] else { continue }
                for cfg in content.obstacleConfigs where cfg.unburnedOnly {
                    if loadedObstacles[cfg.id] != nil {
                        if spawnedIds.contains(cfg.id) {
                            loadedObstacles[cfg.id]?.refcount += 1
                        }
                        continue
                    }
                    spawnObstacle(cfg, in: scene)
                    spawnedIds.insert(cfg.id)
                }
            }
        }
    }

    private func spawnObstacle(_ cfg: ObstacleConfig, in scene: GameScene) {
        let chosenName = obstacleTextureName(for: cfg)
        guard let tex = obstacleCache.acquire(chosenName) else { return }
        let obs = ObstacleEntity(config: cfg, texture: tex)
        scene.register(obs)
        if let n = obs.node {
            n.position = cfg.position
            scene.addChild(n)
        }
        loadedObstacles[cfg.id] = LoadedObstacle(entity: obs, refcount: 1, textureName: chosenName, config: cfg)
    }

    private func obstacleTextureName(for cfg: ObstacleConfig) -> String {
        if burnActive, let burnName = cfg.burnTextureName { return burnName }
        return cfg.textureName
    }

    private func chunkIndex(_ coord: ChunkCoord) -> Int {
        coord.row * registry.gridCols + coord.col
    }

    private func currentBackgroundFileName(for coord: ChunkCoord, base: String) -> String {
        guard burnActive, burnIndices.contains(chunkIndex(coord)) else { return base }
        let idx = chunkIndex(coord)
        return "chunk_\(idx)_burn.png"
    }

    // MARK: - load / unload

    private func load(_ coord: ChunkCoord) {
        guard var content = contents[coord], let scene = scene else { return }

        // Background — async decode, attach on main.
        loadBackgroundAsync(coord: coord, fileName: currentBackgroundFileName(for: coord, base: content.backgroundImageFileName))

        // Obstacles — cheap, stay sync. Dedupe across chunks: a tall obstacle
        // bucketed into two chunks should only spawn one entity.
        for cfg in content.obstacleConfigs {
            // Burn-only configs stay dormant until burn-mode activates; they're
            // spawned by setBurned() at flip time.
            if cfg.burnOnly && !burnActive { continue }
            if cfg.unburnedOnly && burnActive { continue }
            if loadedObstacles[cfg.id] != nil {
                loadedObstacles[cfg.id]?.refcount += 1
                continue
            }
            spawnObstacle(cfg, in: scene)
        }

        // Particles — cheap.
        for pcfg in content.particleConfigs {
            if let emitter = SKEmitterNode(fileNamed: pcfg.fileName) {
                emitter.position = pcfg.position
                if let s = pcfg.particleSize { emitter.particleSize = s }
                emitter.zPosition = pcfg.zPosition
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
        let generation = (loadGeneration[coord] ?? 0) + 1
        loadGeneration[coord] = generation
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

            // Build texture off-main and force GPU upload via preload before
            // we ever touch the scene graph. Without preload, the first draw
            // uploads the bitmap to the GPU on the main thread = frame hitch.
            let texture = SKTexture(image: image)
            texture.filteringMode = .nearest
            texture.preload {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.pendingBackground.remove(coord)
                    // Camera may have already moved away by the time we got here.
                    guard self.active.contains(coord) else { return }
                    // Burn-mode flipped mid-decode? Stale result — drop it
                    guard self.loadGeneration[coord] == generation else { return }
                    self.backgroundTextures[coord] = texture
                    self.attachBackgroundNode(coord: coord, texture: texture)
                }
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

        // Decrement refcount per obstacle id; only tear down when no other
        // active chunk references it anymore.
        for cfg in content.obstacleConfigs {
            guard var loaded = loadedObstacles[cfg.id] else { continue }
            loaded.refcount -= 1
            if loaded.refcount <= 0 {
                loaded.entity.node?.removeFromParent()
                obstacleCache.release(loaded.textureName)
                loadedObstacles.removeValue(forKey: cfg.id)
            } else {
                loadedObstacles[cfg.id] = loaded
            }
        }
        // Particle emitters own their own textures internally — nothing to release here.
    }

    // MARK: - loaders

    private static func makeAssetLoader() -> TextureRefCache.Loader {
        return { name in SKTexture(imageNamed: name) }
    }
}
