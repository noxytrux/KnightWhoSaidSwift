//
//  KWSCommon.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 02.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import Foundation
import UIKit

enum KWSPacketType : Int {
    case HearBeat
    case Connect
    case Disconnect
    case Move
    case Jump
    case Attack
    case Defense
}

let kKWSWriteUUID : String! = "1E832CE0-FE05-4B93-90E4-870FF08DA162"
let kKWSReadUUID  : String! = "0024F793-D583-43B2-A4C7-976CBCA33312"
let KKWServiceUUID : String! = "07547DC7-FCFE-4827-8694-01788139B5B7"

