//
//  YSortSystem.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import GameplayKit

final class YSortSystem {
    private let system = GKComponentSystem(componentClass: YSortComponent.self)

    func register(_ entity: GKEntity) {
        system.addComponent(foundIn: entity)
    }

    func remove(_ entity: GKEntity) {
        system.removeComponent(foundIn: entity)
    }

    func update(deltaTime: TimeInterval) {
        system.update(deltaTime: deltaTime)
    }
}
