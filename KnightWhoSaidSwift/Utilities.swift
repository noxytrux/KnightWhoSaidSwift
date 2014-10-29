//
//  Utilities.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 18.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

struct mapDataStruct {
    
    var object: UInt32 //BGRA!
    
    var playerSpawn: UInt8 {
        
        return UInt8(object & 0x000000FF)
    }
    
    var ground: UInt8 {
        
        return UInt8((object & 0x0000FF00) >> 8)
    }
    
    var grass: UInt8 {
        
        return UInt8((object & 0x00FF0000) >> 16)
    }
    
    var wall: UInt8 {
        
        return UInt8((object & 0xFF000000) >> 24)
    }
    
    var desc : String {
    
        return "(\(self.ground),\(self.grass),\(self.wall),\(self.playerSpawn))"
    }
}

func createARGBBitmapContext(inImage: CGImage) -> CGContext {
    
    var bitmapByteCount = 0
    var bitmapBytesPerRow = 0
    
    let pixelsWide = CGImageGetWidth(inImage)
    let pixelsHigh = CGImageGetHeight(inImage)
    
    bitmapBytesPerRow = Int(pixelsWide) * 4
    bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapData = malloc(CUnsignedLong(bitmapByteCount))
    let bitmapInfo = CGBitmapInfo( UInt32(CGImageAlphaInfo.PremultipliedFirst.rawValue) )
    
    let context = CGBitmapContextCreate(bitmapData,
                                        pixelsWide,
                                        pixelsHigh,
                                        CUnsignedLong(8),
                                        CUnsignedLong(bitmapBytesPerRow),
                                        colorSpace,
                                        bitmapInfo)
    
    return context
}

func loadMapData(mapName: String) -> (data: UnsafeMutablePointer<Void>, width: UInt, height: UInt) {
    
    let image = UIImage(named: mapName)
    let inImage = image?.CGImage

    let cgContext = createARGBBitmapContext(inImage!)
    
    let imageWidth = CGImageGetWidth(inImage)
    let imageHeight = CGImageGetHeight(inImage)
    
    var rect = CGRectZero
    rect.size.width = CGFloat(imageWidth)
    rect.size.height = CGFloat(imageHeight)
    
    CGContextDrawImage(cgContext, rect, inImage)
    
    let dataPointer = CGBitmapContextGetData(cgContext)
    
    return (dataPointer, imageWidth, imageHeight)
}

func loadFramesFromAtlas(atlas: SKTextureAtlas) -> [SKTexture] {
    
    return (atlas.textureNames as [String]).map { atlas.textureNamed($0) }
}

func loadFramesFromAtlasWithName(atlasName: String,
                             #baseFileName: String,
                           #numberOfFrames: Int) -> [SKTexture] {
    
    let atlas = SKTextureAtlas(named: atlasName)
    
    return [SKTexture](
        
        map(1...numberOfFrames) { i in
        
            let fileName = "\(baseFileName)_prefix_\(i).png"
        
            return atlas.textureNamed(fileName)
        }
    )
}

extension SKEmitterNode {
    
    //broken in xCode 6.0 :( works only in 6.1Beta
    class func emitterNodeWithName(name: String) -> SKEmitterNode {
        
        return NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource(name, ofType: "sks")!) as SKEmitterNode
    }
    
    class func sharedSmokeEmitter() -> SKEmitterNode {
    
        var smoke = SKEmitterNode()
        
        smoke.particleTexture = SKTexture(imageNamed: "particle1.png")
        smoke.particleColor = UIColor.blackColor()
        smoke.numParticlesToEmit = 10
        smoke.particleBirthRate = 100
        smoke.particleLifetime = 1
        smoke.emissionAngleRange = 360
        smoke.particleSpeed = 100
        smoke.particleSpeedRange = 50
        smoke.xAcceleration = 0
        smoke.yAcceleration = 200
        smoke.particleAlpha = 0.8
        smoke.particleAlphaRange = 0.2
        smoke.particleAlphaSpeed = -0.5
        smoke.particleScale = 0.6
        smoke.particleScaleRange = 0.4
        smoke.particleScaleSpeed = -0.5
        smoke.particleRotation = 0
        smoke.particleRotationRange = 360
        smoke.particleRotationSpeed = 5
    
        smoke.particleColorBlendFactor = 1
        smoke.particleColorBlendFactorRange = 0.2
        smoke.particleColorBlendFactorSpeed = -0.2
        smoke.particleBlendMode = SKBlendMode.Alpha
        
        return smoke
    }
    
    class func sharedBloodEmitter() -> SKEmitterNode {
        
        var blood = SKEmitterNode()
        
        blood.particleTexture = SKTexture(imageNamed: "particle0.png")
        blood.particleColor = UIColor.redColor()
        blood.numParticlesToEmit = 35
        blood.particleBirthRate = 200
        blood.particleLifetime = 1.5
        blood.emissionAngleRange = 360
        blood.particleSpeed = 50
        blood.particleSpeedRange = 20
        blood.xAcceleration = 0
        blood.yAcceleration = 0
        blood.particleAlpha = 0.8
        blood.particleAlphaRange = 0.2
        blood.particleAlphaSpeed = -0.5
        blood.particleScale = 1.5
        blood.particleScaleRange = 0.4
        blood.particleScaleSpeed = -0.5
        blood.particleRotation = 0
        blood.particleRotationRange = 0
        blood.particleRotationSpeed = 0
        
        blood.particleColorBlendFactor = 1
        blood.particleColorBlendFactorRange = 0
        blood.particleColorBlendFactorSpeed = 0
        blood.particleBlendMode = SKBlendMode.Alpha
        
        return blood
    }
    
    class func sharedSparkleEmitter() -> SKEmitterNode {
        
        var sparcle = SKEmitterNode()
        
        sparcle.particleTexture = SKTexture(imageNamed: "particle2.png")
        sparcle.particleColor = UIColor.yellowColor()
        sparcle.numParticlesToEmit = 60
        sparcle.particleBirthRate = 250
        sparcle.particleLifetime = 0.7
        sparcle.emissionAngle = 0
        sparcle.emissionAngleRange = 90
        sparcle.particleSpeed = 100
        sparcle.particleSpeedRange = 50
        sparcle.xAcceleration = 0
        sparcle.yAcceleration = 0
        sparcle.particleAlpha = 0.8
        sparcle.particleAlphaRange = 0.2
        sparcle.particleAlphaSpeed = -0.5
        sparcle.particleScale = 1.0
        sparcle.particleScaleRange = 0.4
        sparcle.particleScaleSpeed = -0.5
        sparcle.particleRotation = 0
        sparcle.particleRotationRange = 0
        sparcle.particleRotationSpeed = 0
        
        sparcle.particleColorBlendFactor = 1
        sparcle.particleColorBlendFactorRange = 0
        sparcle.particleColorBlendFactorSpeed = 0
        sparcle.particleBlendMode = SKBlendMode.Add
        
        return sparcle
    }
}

func runOneShotEmitter(emitter: SKEmitterNode, withDuration duration: CGFloat) {
    
    let waitAction = SKAction.waitForDuration(NSTimeInterval(duration))
    let birthRateSet = SKAction.runBlock { emitter.particleBirthRate = 0.0 }
    let waitAction2 = SKAction.waitForDuration(NSTimeInterval(emitter.particleLifetime + emitter.particleLifetimeRange))
    let removeAction = SKAction.removeFromParent()
    
    var sequence = [ waitAction, birthRateSet, waitAction2, removeAction]
    emitter.runAction(SKAction.sequence(sequence))
}


