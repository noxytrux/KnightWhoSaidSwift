//
//  SKVelocitySpriteNode.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 30.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

class KWSVelocitySpriteNode: SKSpriteNode {
    
    internal var acceleration : CGPoint
    
    init(imageNamed name: String) {
        acceleration = CGPointMake(10.0 + CGFloat(Int(rand()) % 40), 0)
        
        let texture : SKTexture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: nil, size: texture.size())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateVelocity(time: CFTimeInterval) {
    
        let velocity = self.acceleration * CGFloat(time)
        self.position += velocity
    }
}
