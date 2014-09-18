//
//  GameScene.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 27.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

class KWSMainMenuScene: SKBaseScene {
        
    func loadBottomPart() {
    
        let step : CGFloat = CGRectGetMaxX(self.frame) / kKWSBlockSize
        let iterations = Int32(ceil(Float(step)))
        
        var imageAtlas = SKTextureAtlas(named:"Enviro.atlas")
        
        for (index, obj) in enumerate(1...iterations) {
        
            let sprite = SKSpriteNode(texture:imageAtlas.textureNamed("Enviro_prefix_3"))
            sprite.size = CGSizeMake(32, 32)
            sprite.xScale = 2.0
            sprite.yScale = 2.0
            sprite.zPosition = 1
            
            sprite.position = CGPointMake(CGFloat(index) * kKWSBlockSize + 32.0, 32.0)
            
            self.addChild(sprite)
        }
    }
    
    override func didMoveToView(view: SKView) {

        //take castle node
        var castleNode = self.childNodeWithName("castle") as SKSpriteNode
        let castleSeparator : CGFloat = 20

        self.loadBottomPart()
        self.loadClouds()
        
        //fix castle position
        castleNode.position = CGPointMake(castleNode.position.x, castleNode.size.height * 0.5 + kKWSBlockSize - castleSeparator)
    }
    
    override func update(currentTime: CFTimeInterval) {

        self.animateClouds(currentTime)
    }
}
