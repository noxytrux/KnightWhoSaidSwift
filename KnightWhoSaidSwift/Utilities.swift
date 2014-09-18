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
    let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedFirst.toRaw())!
    
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
    let inImage = image.CGImage

    let cgContext = createARGBBitmapContext(inImage)
    
    let imageWidth = CGImageGetWidth(inImage)
    let imageHeight = CGImageGetHeight(inImage)
    
    var rect = CGRectZero
    rect.size.width = CGFloat(imageWidth)
    rect.size.height = CGFloat(imageHeight)
    
    CGContextDrawImage(cgContext, rect, inImage)
    
    let dataPointer = CGBitmapContextGetData(cgContext)
    
    return (dataPointer, imageWidth, imageHeight)
}


