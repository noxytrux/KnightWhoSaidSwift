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

    func interfaceDidUpdate(#interface: BTLEInterface, command: KWSPacketType, data: NSData!)
}

class KWSBluetoothLEInterface: NSObject, BTLEInterface {
    
    var delegate : KWSBlueToothLEDelegate?
    var ownerViewController : UIViewController?
    
    func sendCommand(#command: KWSPacketType, data: NSData!) {
        
        self.doesNotRecognizeSelector(Selector(__FUNCTION__))
    }
}
