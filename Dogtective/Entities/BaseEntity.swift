//
//  BaseEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import GameplayKit

class BaseEntity: GKEntity {
    init(node: SKNode) {
        super.init()
        addComponent(GKSKNodeComponent(node: node))
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var node: SKNode? {
        component(ofType: GKSKNodeComponent.self)?.node
    }
}
