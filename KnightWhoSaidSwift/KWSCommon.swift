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

enum KWSPacketType : Int8 {
    
    case HearBeat
    case Connect
    case Disconnect
    case MoveUp
    case MoveDown
    case Jump
    case Attack
    case DefenseUp
    case DefenseDown
    case Restart
    case GameEnd
}

enum KWSActionType : Int {
    
    case AttackAction
    case JumpAction
    case WalkAction
    case DieAction
    case DefenseAction
    case HitAction
    case IdleAction
}

let kKWSWriteUUID : String! = "1E832CE0-FE05-4B93-90E4-870FF08DA162"
let kKWSReadUUID  : String! = "0024F793-D583-43B2-A4C7-976CBCA33312"
let kKWServiceUUID : String! = "07547DC7-FCFE-4827-8694-01788139B5B7"

let kKWSMaxPacketSize : Int! = 20
let kKWSBlockSize : CGFloat! = 64.0
let kKWSAnimationDuration : NSTimeInterval! = 0.3
let kKWSPacketRoonLoopTime : Double! = 0.2

extension SKNode {
    
    class func unarchiveFromFile(file : String) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        var sceneData:NSData?
        
        do {
            sceneData = try NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe)
        } catch {
            print("Error: \(error)")
        }
        
        let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SKScene
        archiver.finishDecoding()
        
        return scene
    }
}

struct syncPacket {
    
    var healt : Int8 = 0
    var posx : UInt16 = 0
}
