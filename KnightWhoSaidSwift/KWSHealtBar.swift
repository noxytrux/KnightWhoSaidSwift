//
//  KWSHealtBar.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 23.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

class KWSHealtBar: SKSpriteNode {
   
    var coloredBar: SKSpriteNode!
    var borderBar: SKSpriteNode!

    override init() {
        
        super.init(texture: nil,
            color: UIColor.clearColor(),
            size: CGSizeMake(128, 20))
        
        self.coloredBar = SKSpriteNode(texture: SKTexture(imageNamed: "barbackground.png"),
            color: UIColor.greenColor(),
            size: CGSizeMake(128, 20))
        
        self.addChild(self.coloredBar)
        
        self.coloredBar.colorBlendFactor = 1.0
        
        self.borderBar = SKSpriteNode(texture: SKTexture(imageNamed: "healtbar.png"),
            color: UIColor.whiteColor(),
            size: CGSizeMake(128, 20))
    
        self.addChild(self.borderBar)
        
        self.coloredBar.anchorPoint = CGPointMake(0.0, 0.5)
        self.borderBar.anchorPoint = CGPointMake(0.0, 0.5)
        
        xScale = 0.25
        yScale = 0.25
        position = CGPointMake(-16, 10)
    }

    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    func updateProgress(#progress: CGFloat) {
    
        var localProgress = progress
        if localProgress < 0.0 {
        
            localProgress = 0.0
        }
        
        let barSize = localProgress * 128.0
        let lifeColor = localProgress * 60.0 //hue hue 60 -> Int
        
        var r : CGFloat = (32.0 + 2.0 * (60.0 - lifeColor)) / 255.0
        var g : CGFloat = (32.0 + 2.0 * lifeColor) / 255.0
        var b : CGFloat = 32.0 / 255.0
        
        self.coloredBar.color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        self.coloredBar.size = CGSizeMake(barSize, self.coloredBar.size.height);
    }
    
}
