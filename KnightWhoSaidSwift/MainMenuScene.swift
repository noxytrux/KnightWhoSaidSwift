//
//  GameScene.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 27.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    internal var menuClouds = [SKVelocitySpriteNode]()
    internal var previousUpdateTime : CFTimeInterval = 0.0
    internal let kKWSBlockSize : CGFloat = 64.0
    
    func loadClouds() {
        
        let maxClouds = 10;
        
        for _ in 1...maxClouds {
            
            let sprite = SKVelocitySpriteNode(imageNamed:"cloud")
            
            let localScale : CGFloat = CGFloat.random(0.8, maximum: 3.0);
            
            sprite.xScale = localScale
            sprite.yScale = localScale
            sprite.zPosition = 1
            
            let maxWidth = CGRectGetMaxX(self.frame)
            let posX = CGFloat.random(0, maximum: maxWidth)
            let posY = CGFloat.random(0, maximum: 200)
        
            sprite.position = CGPointMake(posX, CGRectGetMaxY(self.frame) - posY)
            
            self.menuClouds += sprite;
            
            self.addChild(sprite)
            
        }

    }
    
    func loadBottomPart() {
    
        let step : CGFloat = CGRectGetMaxX(self.frame) / kKWSBlockSize;
        let iterations = Int32(ceil(Float(step)))
        
        var imageAtlas = SKTextureAtlas(named:"Enviro.atlas")
        
        for (index, obj) in enumerate(1...iterations) {
        
            let sprite = SKSpriteNode(texture:imageAtlas.textureNamed("Enviro_prefix_3"))
            sprite.size = CGSizeMake(32, 32);
            sprite.xScale = 2.0
            sprite.yScale = 2.0
            sprite.zPosition = 1
            
            sprite.position = CGPointMake(CGFloat(index) * kKWSBlockSize + 32.0, 32.0)
            
            self.addChild(sprite)
        }
    }
    
    func animateClouds(currentTime: CFTimeInterval) {
    
        var delta : CFTimeInterval = currentTime - self.previousUpdateTime
        self.previousUpdateTime = currentTime;
        
        if delta > 0.3 {
            delta = 0.3
        }
    
        for cloud in self.menuClouds {
        
            cloud.updateVelocity(delta)
            
            var pos = cloud.position.x - cloud.size.width*0.5
            var maxWidth = CGRectGetMaxX(self.frame)
            
            if  pos > maxWidth {
                
                cloud.position = CGPointMake(-cloud.size.width, cloud.position.y)
                
                let localScale : CGFloat = CGFloat.random(0.8, maximum: 3.0)
                
                cloud.xScale = localScale
                cloud.yScale = localScale
            }
        }
    }
    
    override func didMoveToView(view: SKView) {

        //take castle node
        var castleNode = self.childNodeWithName("castle") as SKSpriteNode;
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
