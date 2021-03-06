//
//  KWSBluetoothLEInterface.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 08.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit

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

protocol KWSBlueToothLEDelegate: class {

    func interfaceDidUpdate(interface interface: KWSBluetoothLEInterface, command: KWSPacketType, data: NSData?)
}

class KWSBluetoothLEInterface: NSObject {
    
    weak var delegate : KWSBlueToothLEDelegate?
    weak var ownerViewController : UIViewController?

    var interfaceConnected : Bool = false

    init(ownerController : UIViewController, delegate: KWSBlueToothLEDelegate) {
        
        self.ownerViewController = ownerController
        self.delegate = delegate
        super.init()
    }
    
    func sendCommand(command command: KWSPacketType, data: NSData?) {
        
        self.doesNotRecognizeSelector(Selector(__FUNCTION__))
    }
}
