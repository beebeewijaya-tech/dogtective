//
//  MapSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit

// MARK: - Map System

/// will contains the setup about the map, map position
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
        guard let gameSettingsViewModel = gameSettingsViewModel else { return }
        
        
        var pos = playerParkPosition
        if gameSettingsViewModel.playerPosition.x != 0 && gameSettingsViewModel.playerPosition.y != 0 {
            // if player position has been altered
            // from quest, cutscene, etc
            pos = gameSettingsViewModel.playerPosition
        }
        
        register(playerEntity)
        addEntity(playerEntity, position: pos)
        // DEFAULT IS CGPoint(x: -854, y: 34))

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
        setupChunkedWorld()
        setupColliders()
    }

    func setupChunkedWorld() {
        let mapSize = CGSize(width: 3934, height: 1649)
        let mapOrigin = CGPoint(x: size.width / 2 - mapSize.width / 2,
                                y: size.height / 2 - mapSize.height / 2)
        let registry = ChunkRegistry(
            mapOriginBottomLeft: mapOrigin,
            mapSize: mapSize,
            gridCols: 8,
            gridRows: 4
        )

        // Assign stable ids and bucket each obstacle into EVERY chunk its
        // visual bounding rect overlaps — not just the chunk that contains
        // its anchor point. Tall buildings have anchors near the bottom of
        // the sprite but extend upward; without this, the chunk above misses
        // the building and it disappears when the player is north of it.
        // ChunkManager dedupes by id so the entity only instantiates once.
        var obstaclesByChunk: [ChunkCoord: [ObstacleConfig]] = [:]
        let rawConfigs = allObstacleConfigs()
        for (index, raw) in rawConfigs.enumerated() {
            var cfg = raw
            cfg.id = index
            let rect = visualRect(for: cfg)
            for coord in registry.chunks(overlapping: rect) {
                obstaclesByChunk[coord, default: []].append(cfg)
            }
        }

        var particlesByChunk: [ChunkCoord: [ParticleConfig]] = [:]
        for pc in allParticleConfigs() {
            let coord = registry.chunkCoord(for: pc.position)
            particlesByChunk[coord, default: []].append(pc)
        }

        var contents: [ChunkCoord: ChunkContent] = [:]
        for col in 0..<8 {
            for row in 0..<4 {
                let c = ChunkCoord(col: col, row: row)
                contents[c] = ChunkContent(
                    coord: c,
                    backgroundImageFileName: registry.backgroundFileName(for: c),
                    obstacleConfigs: obstaclesByChunk[c] ?? [],
                    particleConfigs: particlesByChunk[c] ?? []
                )
            }
        }

        let mgr = ChunkManager(
            scene: self,
            registry: registry,
            contents: contents,
            activeRadius: 1
        )
        self.chunkManager = mgr

        // Kick async decode for chunks around the player spawn point right now,
        // so by the time the scene-transition fade finishes, the textures are
        // ready and the first frame doesn't hitch. Player spawns at (603, 597)
        // per `setupPlayer()` — keep this in sync if that ever changes.
        mgr.update(cameraPosition: CGPoint(x: 603, y: 597))
    }

    private func allObstacleConfigs() -> [ObstacleConfig] {
        return [
            // MARK: - Big Tree Entity
            // HOUSE - LEFT
            .bigTree(at: CGPoint(x: -973, y: -475)),
            // PLAYGROUND
            .bigTree(at: CGPoint(x: 633, y: 734)),
            .bigTree(at: CGPoint(x: 550, y: 671), zOffset: 1),
            .bigTree(at: CGPoint(x: 1154, y: 719)),
            // PARK
            .bigTree(at: CGPoint(x: 1368, y: 696), zOffset: 1, burns: true),
            .bigTree(at: CGPoint(x: 1456, y: 772), burns: true),
            .bigTree(at: CGPoint(x: 1576, y: 569), zOffset: 2, burns: true),
            .bigTree(at: CGPoint(x: 1383, y: 404), burns: true),
            .bigTree(at: CGPoint(x: 1577, y: 414), zOffset: 3, burns: true),
            .bigTree(at: CGPoint(x: 2080, y: 391), zOffset: 3, burns: true),
            .bigTree(at: CGPoint(x: 2144, y: 467), zOffset: 2, burns: true),
            // HOUSE - RIGHT
            .bigTree(at: CGPoint(x: 2313, y: -548)),
            .bigTree(at: CGPoint(x: 1855, y: -273)),
            .bigTree(at: CGPoint(x: 1519, y: -549)),
            
            // MARK: - Cone Tree Entity
            // PARK
            .coneTree(at: CGPoint(x: 1369, y: 580), zOffset: 3, burns: true),
            .coneTree(at: CGPoint(x: 1485, y: 536), zOffset: 4, burns: true),
            .coneTree(at: CGPoint(x: 1707, y: 703), zOffset: 1, burns: true),
            .coneTree(at: CGPoint(x: 1786, y: 637), zOffset: 2, burns: true),
            .coneTree(at: CGPoint(x: 1841, y: 735), burns: true),
            .coneTree(at: CGPoint(x: 2020, y: 781), burns: true),
            .coneTree(at: CGPoint(x: 2139, y: 755), burns: true),
            .coneTree(at: CGPoint(x: 2200, y: 701), zOffset: 1, burns: true),
            .coneTree(at: CGPoint(x: 2144, y: 636), zOffset: 2, burns: true),
            .coneTree(at: CGPoint(x: 1939, y: 577), burns: true),
            // BACKHOUSE
            .coneTree(at: CGPoint(x: -371, y: 826)),
            .coneTree(at: CGPoint(x: -315, y: 743), zOffset: 1),
            .coneTree(at: CGPoint(x: -393, y: 711), zOffset: 2),
            .coneTree(at: CGPoint(x: 164, y: 801), zOffset: 3),
            
            // MARK: - Bulding
            // coffe shop
            .building(at: CGPoint(x: -74, y: 541), textureName: "apart_top"),
            .buildingFullCollision(at: CGPoint(x: 77, y: 40), textureName: "apart_coffe_shop", zOffset: 3),
            // Unique Building
            ObstacleConfig(
                textureName: "coffe_shop",
                position: CGPoint(x: -155, y: 382),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.4,                      
                collisionWidthRatio: 0.7,
                collisionHeightRatio: 0.6,
                ysortEnabled: true,
                firstPieceZ: 0,
                secondPieceZ: 1,
                zOffset: 1),
            
            // coffe shop - left
            .building(at: CGPoint(x: -832, y: 605), textureName: "house_3"),
            
            // building - left
            .building(at: CGPoint(x: -1339, y: 478), textureName: "house_1"),
            
            // building - left middle
            ObstacleConfig(
                textureName: "supermarket",
                position: CGPoint(x: -1384, y: -18),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.7,
                collisionWidthRatio: 0.8,
                collisionHeightRatio: 0.94,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            
            // building - left bottom
            .building(at: CGPoint(x: -1313, y: -485), textureName: "house_2"),
            ObstacleConfig(
                textureName: "apart_burger",
                position: CGPoint(x: -742, y: -718),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.75,
                collisionWidthRatio: 0.9,
                collisionHeightRatio: 0.9,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            
            // building - bottom middle
            ObstacleConfig(
                textureName: "apart_middle_bottom_left",
                position: CGPoint(x: -40, y: -509),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.55,
                collisionWidthRatio: 0.9,
                collisionHeightRatio: 0.9,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            ObstacleConfig(
                textureName: "apart_middle_bottom_right",
                position: CGPoint(x: 180, y: -588),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.75,
                collisionWidthRatio: 0.9,
                collisionHeightRatio: 0.9,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            
            
            // building - bottom left
            .building(at: CGPoint(x: 858, y: -519), textureName: "apart_middle_bottom_2"),
            ObstacleConfig(
                textureName: "house_4",
                position: CGPoint(x: 1192, y: -495),
                scale: 0.33,
                axis: .vertical,
                ratio: 1.0,
                collisionWidthRatio: 0.85,
                collisionHeightRatio: 0.5,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            ObstacleConfig(
                textureName: "house_5",
                position: CGPoint(x: 1721, y: -485),
                scale: 0.38,
                axis: .vertical,
                ratio: 1.0,
                collisionWidthRatio: 0.8,
                collisionHeightRatio: 0.6,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            
            // building - bottom right
            .building(at: CGPoint(x: 2121, y: -37), textureName: "apart_middle_right"),
            ObstacleConfig(
                textureName: "apart_middle_left_side",
                position: CGPoint(x: 845, y: -43),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.7,
                collisionWidthRatio: 1.0,
                collisionHeightRatio: 0.7,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            .building(at: CGPoint(x: 1053, y: 1), textureName: "apart_middle_right_side"),
            
            // Police Station
            ObstacleConfig(
                textureName: "police_station",
                position: CGPoint(x: -810, y: 29),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.75,
                collisionWidthRatio: 0.97,
                collisionHeightRatio: 0.9,
                ysortEnabled: true,
                secondPieceZ: 1000,
                zOffset: 0
            ),
            
            // MARK: - Small Obstacle Entity
            // Playground and Park
            .smallObstacle(at: CGPoint(x: 565, y: 612), textureName: "park_horse"),
            .smallObstacle(at: CGPoint(x: 575, y: 552), textureName: "park_horse"),
            .smallObstacle(at: CGPoint(x: 805, y: 692), textureName: "park_slide"),
            .smallObstacle(at: CGPoint(x: 1123, y: 588), textureName: "park_swing"),
            .smallObstacle(at: CGPoint(x: 989, y: 657), textureName: "park_see_saw"),
            .pole(at: CGPoint(x: 518, y: 490), textureName: "standing_lamp"),
            .pole(at: CGPoint(x: 495, y: 406), textureName: "traffic_light"),
            .pole(at: CGPoint(x: 1639, y: 297), textureName: "cross_sign"),
            .smallObstacle(at: CGPoint(x: 1999, y: 539), textureName: "log_2", burnTextureName: "log_2_burn"),
            .smallObstacle(at: CGPoint(x: 1693, y: 580), textureName: "log_2", burnTextureName: "log_2_burn"),
            .smallObstacle(at: CGPoint(x: 774, y: 615), textureName: "log_1"),
            
            // middle section
            .treeOnPot(at: CGPoint(x: 1016, y: -31), textureName: "small_tree_on_pot", zOffset: 1),
            .treeOnPot(at: CGPoint(x: 707, y: -87), textureName: "small_tree_on_pot", zOffset: 2),
            .treeOnPot(at: CGPoint(x: 1571, y: 124), textureName: "small_tree_on_pot"),
            .treeOnPot(at: CGPoint(x: 1571, y: -74), textureName: "small_tree_on_pot"),
            .smallStickyObstacle(at: CGPoint(x: 966, y: -33), textureName: "mail_box", zOffset: 10),
            .smallObstacle(at: CGPoint(x: 1492, y: 122), textureName: "popcorn_stand"),
            .smallObstacle(at: CGPoint(x: 1927, y: 23), textureName: "hotdog_stand"),
            .smallObstacle(at: CGPoint(x: 1790, y: 67), textureName: "cafe_table"),
            .smallObstacle(at: CGPoint(x: 1800, y: -5), textureName: "cafe_table"),
            .smallObstacle(at: CGPoint(x: 1670, y: -74), textureName: "bench_front"),
            .smallObstacle(at: CGPoint(x: 1472, y: -74), textureName: "bench_front"),
            .smallObstacle(at: CGPoint(x: 1161, y: 107), textureName: "big_trash_bin"),
            .smallObstacle(at: CGPoint(x: 1200, y: 107), textureName: "box_no_open", zOffset: 5),
            .pole(at: CGPoint(x: 1895, y: 143), textureName: "standing_lamp"),
            
            // middle coffe shop section
            .smallObstacle(at: CGPoint(x: -83, y: 298), textureName: "cafe_table"),
            .smallObstacle(at: CGPoint(x: -83, y: 225), textureName: "cafe_table"),
            .smallObstacle(at: CGPoint(x: -72, y: 75), textureName: "popcorn_stand"),
            .smallObstacle(at: CGPoint(x: -167, y: 75), textureName: "hotdog_stand"),
            .treeOnPot(at: CGPoint(x: -280, y: 521), textureName: "small_tree_on_pot", zOffset: 1),
            
            // police station
            .treeOnPot(at: CGPoint(x: -506, y: 291), textureName: "big_tree_on_pot", zOffset: 2),
            ObstacleConfig(
                textureName: "fence_police_station",
                position: CGPoint(x: -726, y: 350),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.35,
                collisionWidthRatio: 0.97,
                collisionHeightRatio: 0.9,
                ysortEnabled: true,
                secondPieceZ: 0,
                zOffset: 0
                
            ),
            
            // bottom middle section
            .pole(at: CGPoint(x: -193, y: -139), textureName: "standing_lamp"),
            .pole(at: CGPoint(x: 454, y: -139), textureName: "standing_lamp"),
            .car(at: CGPoint(x: 390, y: -267), textureName: "car_red"),
            .car(at: CGPoint(x: 390, y: -361), textureName: "car_blue", zOffset: 1),
            .car(at: CGPoint(x: 390, y: -545), textureName: "car_green", zOffset: 2),
            
            // bottom right section
            .treeOnPot(at: CGPoint(x: 696, y: -262), textureName: "small_tree_on_pot"),
            .smallObstacle(at: CGPoint(x: 929, y: -530), textureName: "big_trash_bin"),
            
            // bottom left section
            ObstacleConfig(
                textureName: "bus_stop",
                position: CGPoint(x: -504, y: -419),
                scale: 0.33,
                axis: .vertical,
                ratio: 0.75,
                collisionWidthRatio: 0.97,
                collisionHeightRatio: 0.9,
                ysortEnabled: true,
                secondPieceZ: 0,
                zOffset: 0
            ),
            .smallObstacle(at: CGPoint(x: -454, y: -423), textureName: "bus_stop_sign"),
            .pole(at: CGPoint(x: -454, y: -206), textureName: "traffic_light"),
            .pole(at: CGPoint(x: -808, y: -240), textureName: "standing_lamp"),
            .treeOnPot(at: CGPoint(x: -863, y: -238), textureName: "small_tree_on_pot"),
            .treeOnPot(at: CGPoint(x: -599, y: -238), textureName: "small_tree_on_pot"),
            
            // left section
            .pole(at: CGPoint(x: -1197, y: 289), textureName: "cross_sign"),
            
            // top section
            .pole(at: CGPoint(x: -624, y: 514), textureName: "cross_sign"),
            
            // MARK: - Bush detail effect
            .bushObstacle(at: CGPoint(x: -471, y: 663), textureName: "bush_small"),
            .bushObstacle(at: CGPoint(x: -462, y: 594), textureName: "bush_small"),
            .bushObstacle(at: CGPoint(x: -373, y: 545), textureName: "bush", zOffset: 3),
            .bushObstacle(at: CGPoint(x: -1305, y: -42), textureName: "mini_pot_horizontal", zOffset: 3),
            .bushObstacle(at: CGPoint(x: -1402, y: -42), textureName: "mini_pot_horizontal", zOffset: 3),
            .bushObstacle(at: CGPoint(x: -958, y: -227), textureName: "bush", zOffset: 3),
            
            // Bottom right
            .bushObstacle(at: CGPoint(x: 1000, y: -275), textureName: "bush_small", zOffset: 3),
            .bushObstacle(at: CGPoint(x: 1006, y: -529), textureName: "bush_small", zOffset: 3),
            .bushObstacle(at: CGPoint(x: 1530, y: -279), textureName: "bush_small", zOffset: 3),
            
            // Park and Playground (only visible before park burns)
            .bushObstacle(at: CGPoint(x: 2121, y: 649), textureName: "bush_small", zOffset: 3, unburnedOnly: true),
            .bushObstacle(at: CGPoint(x: 2211, y: 440), textureName: "bush_small", zOffset: 3, unburnedOnly: true),
            .bushObstacle(at: CGPoint(x: 2068, y: 735), textureName: "bush_small", zOffset: 3, unburnedOnly: true),
            .bushObstacle(at: CGPoint(x: 1603, y: 727), textureName: "bush_small", zOffset: 3, unburnedOnly: true),
            .bushObstacle(at: CGPoint(x: 1426, y: 775), textureName: "bush_small", zOffset: 3, unburnedOnly: true),
            .bushObstacle(at: CGPoint(x: 1439, y: 415), textureName: "bush_small", zOffset: 3, unburnedOnly: true),
            .bushObstacle(at: CGPoint(x: 1603, y: 423), textureName: "bush_small", zOffset: 3, unburnedOnly: true),

            .grassObstacle(at: CGPoint(x: 2093, y: 385),textureName: "grass_big", zOffset: 6, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 1837, y: 578),textureName: "grass_big", zOffset: 6, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 1497, y: 408),textureName: "grass_big", zOffset: 6, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 1422, y: 575),textureName: "grass_big", zOffset: 6, unburnedOnly: true),

            .grassObstacle(at: CGPoint(x: 1805, y: 629), textureName: "grass_small", zOffset: 8, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 2012, y: 771), textureName: "grass_small", zOffset: 8, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 2157, y: 631), textureName: "grass_small", zOffset: 8, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 2219, y: 716), textureName: "grass_small", zOffset: 8, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 2147, y: 462), textureName: "grass_small", zOffset: 8, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 1504, y: 532), textureName: "grass_small", zOffset: 8, unburnedOnly: true),
            .grassObstacle(at: CGPoint(x: 1378, y: 570), textureName: "grass_small", zOffset: 10, unburnedOnly: true),
            
            
            
            // MARK: - Burn things only
            .smallObstacle(at: CGPoint(x: 1482, y: 534), textureName: "dig_raw",  zOffset: 5, burnOnly: true),
            .smallObstacle(at: CGPoint(x: 1749, y: 705), textureName: "dig_raw",  zOffset: 5, burnOnly: true),
            .smallObstacle(at: CGPoint(x: 1971, y: 596), textureName: "dig_raw", zOffset: 5, burnOnly: true),
            .smallObstacle(at: CGPoint(x: 2157, y: 486), textureName: "dig_raw", zOffset: 5, burnOnly: true),
            .smallObstacle(at: CGPoint(x: 2055, y: 779), textureName: "dig_raw", zOffset: 5, burnOnly: true),
        ]
        + ObstacleConfig.fenceLine(from: CGPoint(x: -957, y: 554), direction: .right, count: 4)
        + ObstacleConfig.fenceLine(from: CGPoint(x: -452, y: 554), direction: .left, count: 2)
        + ObstacleConfig.fenceLine(from: CGPoint(x: -1506, y: -189), direction: .right, count: 6)
        + ObstacleConfig.fenceLine(from: CGPoint(x: -957, y: -212), direction: .right, count: 1)
        + ObstacleConfig.fenceLine(from: CGPoint(x: 1013, y: -251), direction: .right, count: 5)
        + ObstacleConfig.fenceLine(from: CGPoint(x: 1455, y: -252), direction: .right, count: 6)
        + ObstacleConfig.fenceLine(from: CGPoint(x: 533, y: 508), direction: .right, count: 4)
        + ObstacleConfig.fenceLine(from: CGPoint(x: 965, y: 508), direction: .right, count: 4)
        
    
    }
    
    // MARK: - Collider Entity
    private func setupColliders() {
          var configs: [ColliderConfig] = allColliderConfigs()
          if (gameSettingsViewModel?.currentCutscene ?? 0) < 4 {
              configs.append(.circle(at: CGPoint(x: 196, y: 780), radius: 40))
          }
          for cfg in configs {
              let collider = ColliderEntity(config: cfg)
              register(collider)
              addEntity(collider, position: cfg.position)
          }
      }
    // TODO: Use chunk too later for collider ( if something wrong)
      private func allColliderConfigs() -> [ColliderConfig] {
          return [
             // coffe shop
             .rect(at: CGPoint(x: -135, y: 495), size: CGSize(width: 230, height: 90)),
             
             // house - coffe shop left
             .rect(at: CGPoint(x: -769, y: 845), size: CGSize(width: 80, height: 130)),
             
             // playground
             .rect(at: CGPoint(x: 1273, y: 842), size: CGSize(width: 1520, height: 20)),
             .rect(at: CGPoint(x: 2195, y: 842), size: CGSize(width: 300, height: 20)),
             .rect(at: CGPoint(x: 2245, y: 615), size: CGSize(width: 20, height: 500)),
             .rect(at: CGPoint(x: 2159, y: 354), size: CGSize(width: 530, height: 30)),
             .rect(at: CGPoint(x: 1010, y: 765), size: CGSize(width: 67, height: 67)),
             
             // vertical fence
             .rect(at: CGPoint(x: 490, y: 764), size: CGSize(width: 28, height: 500)),
             .rect(at: CGPoint(x: 1255, y: 654), size: CGSize(width: 79, height: 650)),
             .rect(at: CGPoint(x: 1452, y: 347), size: CGSize(width: 300, height: 40)),

             // Apart middle top
             .rect(at: CGPoint(x: 342, y: 871), size: CGSize(width: 250 , height: 30)),
             .rect(at: CGPoint(x: 180, y: 928), size: CGSize(width: 30 , height: 200)),
             .rect(at: CGPoint(x: -348, y: 903), size: CGSize(width: 990 , height: 40)),
             .rect(at: CGPoint(x: -567, y: 884), size: CGSize(width: 250 , height: 80)),
             .rect(at: CGPoint(x: -995, y: 790), size: CGSize(width: 30 , height: 450)),
             .rect(at: CGPoint(x: 185, y: 675), size: CGSize(width: 25, height: 120)),
             .rect(at: CGPoint(x: -419, y: 725), size: CGSize(width: 25, height: 350)),
             .rect(at: CGPoint(x: -345, y: 573), size: CGSize(width: 120, height: 35)),
             
             // left top
             .rect(at: CGPoint(x: -1218, y: 872), size: CGSize(width: 500 , height: 50)),
             .rect(at: CGPoint(x: -1430, y: 830), size: CGSize(width: 350 , height: 75)),
             .rect(at: CGPoint(x: -1497, y: 712), size: CGSize(width: 60 , height: 560)),
             
             // bottom left
             .rect(at: CGPoint(x: -1497, y: -391), size: CGSize(width: 60 , height: 560)),
             .rect(at: CGPoint(x: -1218, y: -592), size: CGSize(width: 560 , height: 60)),
             .rect(at: CGPoint(x: -918, y: -460), size: CGSize(width: 30 , height: 560)),
             
             // chair
             .rect(at: CGPoint(x: -496, y: -482), size: CGSize(width: 75 , height: 65)),
             .rect(at: CGPoint(x: -496, y: -570), size: CGSize(width: 75 , height: 65)),
             
             .circle(at: CGPoint(x: 451, y: 144), radius: 120),
             .circle(at: CGPoint(x: 1790, y: 490), radius: 65),
             
             // bottom right
             .rect(at: CGPoint(x: 985, y: -450 ), size: CGSize(width: 35 , height: 415)),
             .rect(at: CGPoint(x: 1582, y: -580), size: CGSize(width: 1200 , height: 30)),
             .rect(at: CGPoint(x: 2291, y: -580), size: CGSize(width: 300 , height: 30)),
             .rect(at: CGPoint(x: 1578, y: -410), size: CGSize(width: 35 , height: 360)),
             
             .rect(at: CGPoint(x: 2281, y: -316), size: CGSize(width: 360 , height: 360)),
             .rect(at: CGPoint(x: 2133, y: -206), size: CGSize(width: 130 , height: 130)),
             .rect(at: CGPoint(x: 2285, y: 125), size: CGSize(width: 100 , height: 720)),
             
             // police station
             .rect(at: CGPoint(x: -454, y: 176), size: CGSize(width: 30, height: 370)),
             .rect(at: CGPoint(x: -1010, y: 176), size: CGSize(width: 30, height: 390)),
          ]
      }

    private func visualRect(for cfg: ObstacleConfig) -> CGRect {
        let tex = SKTexture(imageNamed: cfg.textureName)
        let w = tex.size().width * cfg.scale
        let h = tex.size().height * cfg.scale
        switch cfg.axis {
        case .vertical:
            return CGRect(x: cfg.position.x - w / 2, y: cfg.position.y, width: w, height: h)
        case .horizontal:
            return CGRect(x: cfg.position.x, y: cfg.position.y - h / 2, width: w, height: h)
        case .horizontalReversed:
            return CGRect(x: cfg.position.x - w, y: cfg.position.y - h / 2, width: w, height: h)
        }
    }

    private func allParticleConfigs() -> [ParticleConfig] {
        var out: [ParticleConfig] = []
        for bf in bonfirePositions {
            out.append(ParticleConfig(
                fileName: "BonFire",
                position: bf.position,
                particleSize: CGSize(width: 100, height: 100),
                burnOnly: bf.burnOnly
            ))
        }
        for pos in foodStallPosition {
            out.append(ParticleConfig(fileName: "FoodStallSmoke", position: pos, particleSize: nil))
        }
//        for pos in lampLightPosition {
//            // High z so the lamp glow sits above nearby buildings/canopies.
//            out.append(ParticleConfig(fileName: "Lamp", position: pos, particleSize: nil, zPosition: 2000))
//        }
        return out
    }
}
