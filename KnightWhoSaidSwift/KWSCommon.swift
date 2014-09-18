//
//  KWSCommon.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 02.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

enum KWSPacketType : Int {
    
    case HearBeat
    case Connect
    case Disconnect
    case Move
    case Jump
    case Attack
    case Defense
}

enum KWSSoundType : Int {
    
    case AttackSound
    case JumpSound
    case WalkSound
    case DieSound
    case DefenseSound
    case HitSound
}

let kKWSWriteUUID : String! = "1E832CE0-FE05-4B93-90E4-870FF08DA162"
let kKWSReadUUID  : String! = "0024F793-D583-43B2-A4C7-976CBCA33312"
let kKWServiceUUID : String! = "07547DC7-FCFE-4827-8694-01788139B5B7"

let kKWSMaxPacketSize : Int! = 20

let kKWSBlockSize : CGFloat! = 64.0

extension SKNode {
    
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path!, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as SKScene
        archiver.finishDecoding()
        return scene
    }
}
