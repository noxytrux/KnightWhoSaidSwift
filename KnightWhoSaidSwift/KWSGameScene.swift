//
//  KWSGameScene.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 17.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import SpriteKit

class KWSGameScene: SKBaseScene {
   
    override func didMoveToView(view: SKView) {
    
        self.insertBackgroundNode()
        self.loadClouds()
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        self.animateClouds(currentTime)
    }
    
    func insertBackgroundNode() {
    
        let sprite = SKSpriteNode(imageNamed: "bg")

        sprite.size = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))
        sprite.xScale = 1.0
        sprite.yScale = 1.0
        sprite.zPosition = 0
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(sprite)
    }
}
