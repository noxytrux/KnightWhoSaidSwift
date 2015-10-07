//
//  SKBaseScene.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 11.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

class SKBaseScene: SKScene {
   
    internal var menuClouds = [KWSVelocitySpriteNode]()
    internal var previousUpdateTime : CFTimeInterval = 0.0
    internal var delta : CFTimeInterval = 0.0
    
    func loadClouds() {
        
        let maxClouds = 10
        
        for _ in 1...maxClouds {
            
            let sprite = KWSVelocitySpriteNode(imageNamed:"cloud")
            
            let localScale : CGFloat = CGFloat.random(0.8, maximum: 3.0)
            
            sprite.xScale = localScale
            sprite.yScale = localScale
            sprite.zPosition = 1
            
            let maxWidth = CGRectGetMaxX(self.frame)
            let posX = CGFloat.random(0, maximum: maxWidth)
            let posY = CGFloat.random(0, maximum: 200)
            
            sprite.position = CGPointMake(posX, CGRectGetMaxY(self.frame) - posY)
            
            self.menuClouds.append(sprite)
            
            self.addChild(sprite)
            
        }
        
    }

    func animateClouds(currentTime: CFTimeInterval) {
        
        self.delta = currentTime - self.previousUpdateTime
        self.previousUpdateTime = currentTime
        
        if delta > 0.3 {
            delta = 0.3
        }
        
        for cloud in self.menuClouds {
            
            cloud.updateVelocity(delta)
            
            let pos = cloud.position.x - cloud.size.width*0.5
            let maxWidth = CGRectGetMaxX(self.frame)
            
            if  pos > maxWidth {
                
                cloud.position = CGPointMake(-cloud.size.width, cloud.position.y)
                
                let localScale : CGFloat = CGFloat.random(0.8, maximum: 3.0)
                
                cloud.xScale = localScale
                cloud.yScale = localScale
            }
        }
    }

}
