//
//  KWSBluetoothLEInterface.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 08.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit

protocol BTLEInterface {
    
    var ownerViewController : UIViewController? {get set}
}

protocol KWSBlueToothLEDelegate {

    func interfaceDidUpdate(interface interface: BTLEInterface, command: KWSPacketType, data: NSData?)
}

class KWSBluetoothLEInterface: NSObject, BTLEInterface {
    
    var delegate : KWSBlueToothLEDelegate?
    var ownerViewController : UIViewController?
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
