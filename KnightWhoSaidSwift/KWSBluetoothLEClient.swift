//
//  KWSBlueToothLEClient.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 01.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import CoreBluetooth

class KWSBluetoothLEClient: NSObject, CBPeripheralManagerDelegate  {
   
    var peripheralManager : CBPeripheralManager!
    var peripheralQueue : dispatch_queue_t!
    
    var transferService : CBMutableService? = nil
    var readCharacteristic : CBMutableCharacteristic? = nil
    var writeCharacteristic : CBMutableCharacteristic? = nil
    
    var recivedData : NSData? = nil
    var sendedData : NSData? = nil
    
    override init() {
    
        super.init()
    
        self.peripheralQueue = dispatch_queue_create("com.mp.devs.kwss", nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: self.peripheralQueue)
    }
    
    func sendCommand(#command: KWSPacketType, data: NSData!) {
    
        
    }
    
    func endConnection() {
    
        if self.readCharacteristic == nil {
        
            return;
        }
        
        var packet : Int = KWSPacketType.Disconnect.toRaw()
        self.sendedData = NSData(bytes: &packet, length: sizeof(Int))
        
        var killSignalSend : Bool = self.peripheralManager.updateValue( self.sendedData!,
                                                     forCharacteristic: self.readCharacteristic,
                                                  onSubscribedCentrals: nil)
        
        if killSignalSend {
        
            self.peripheralManager.stopAdvertising()
        }
    }

    func resetConnection() {
    
    }
    
    //MARK: CBPeripheralManagerDelegate method implementation
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
    
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
        
            return;
        }
        
        println("self.peripheralManager powered on.")
        
        self.readCharacteristic = CBMutableCharacteristic(  type: CBUUID.UUIDWithString(kKWSReadUUID),
                                                      properties: CBCharacteristicProperties.Notify,
                                                           value: nil,
                                                     permissions: CBAttributePermissions.Readable)
        
        self.writeCharacteristic = CBMutableCharacteristic( type: CBUUID.UUIDWithString(kKWSWriteUUID),
                                                      properties: CBCharacteristicProperties.Write,
                                                           value: nil,
                                                     permissions: CBAttributePermissions.Writeable)
        
        self.transferService = CBMutableService(type: CBUUID.UUIDWithString(KKWServiceUUID), primary: true)

        self.peripheralManager.addService(self.transferService!)
        
        let delay = 1.0
        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        let options : Dictionary<NSString, AnyObject> = [ CBAdvertisementDataServiceUUIDsKey: CBUUID.UUIDWithString(KKWServiceUUID) ]
        
        dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
            
            self.peripheralManager.startAdvertising(options)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!) {
        
        println("read request: \(request)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        
        println("write request")
        
        if requests.count == 0 {
            
            return;
        }
        
        for req in requests as [CBATTRequest] {
        
            let data : NSData = req.value
            let header : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int)))
            
            let actionValue : UnsafePointer<Int> = UnsafePointer<Int>(header.bytes)
            let action : KWSPacketType = KWSPacketType.fromRaw(actionValue.memory)!
            
            switch action {
            
            case .Disconnect:
                println("disconnect")
                
            case .Attack:
                println("heartBeat")
                
            case .Defense:
                println("heartBeat")
                
            case .Jump:
                println("heartBeat")
                
            case .Move:
                println("heartBeat")
                
            case .HearBeat:
                println("heartBeat")
            
            case .Connect:
                println("connect")
                
            default:
                println("unknown packet")
            }
            
            self.peripheralManager.respondToRequest(req, withResult: CBATTError.Success)
        }
    }
    
    func peripheralManager(              peripheral: CBPeripheralManager!,
                                            central: CBCentral!,
        didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        
        println("Central subscribed to characteristic")
            
        //start sending data here 
            
        self.sendCommand(command: .Connect, data: nil)
    }
    
    func peripheralManager(                  peripheral: CBPeripheralManager!,
                                                central: CBCentral!,
        didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        
        //send end game / abort info here
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        
        println("ready to send next packet")
    }
}
