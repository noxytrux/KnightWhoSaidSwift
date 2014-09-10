//
//  KWSBlueToothLEClient.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 01.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import CoreBluetooth

class KWSBluetoothLEClient: KWSBluetoothLEInterface,
//DELEGATE
CBPeripheralManagerDelegate  {
   
    private var peripheralManager : CBPeripheralManager!
    private var peripheralQueue : dispatch_queue_t!
    private var transferService : CBMutableService? = nil
    private var readCharacteristic : CBMutableCharacteristic? = nil
    private var writeCharacteristic : CBMutableCharacteristic? = nil
    
    internal var recivedData : NSData? = nil
    internal var sendedData : NSData? = nil
    
    override init(ownerController : UIViewController, delegate: KWSBlueToothLEDelegate) {
        
        super.init(ownerController: ownerController, delegate: delegate)
        
        self.peripheralQueue = dispatch_queue_create("com.mp.devs.kwss.client", nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: self.peripheralQueue)
    }
    
    override func sendCommand(#command: KWSPacketType, data: NSData!) {
    
        var header : Int = command.toRaw()
        var dataToSend : NSMutableData = NSMutableData(bytes: &header, length: sizeof(Int))
            dataToSend.appendData(data)
        
        if dataToSend.length > kKWSMaxPacketSize {
            
            println("Error data packet to long!")
            
            return
        }
        
        self.peripheralManager.updateValue( dataToSend,
                         forCharacteristic: self.readCharacteristic,
                      onSubscribedCentrals: nil)
        
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
        
        self.transferService = CBMutableService(type: CBUUID.UUIDWithString(kKWServiceUUID), primary: true)

        self.peripheralManager.addService(self.transferService!)
        
        let delay = 1.0
        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        let options : Dictionary<NSString, AnyObject> = [ CBAdvertisementDataServiceUUIDsKey: CBUUID.UUIDWithString(kKWServiceUUID) ]
        
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
            let body : NSData = data.subdataWithRange(NSMakeRange(sizeof(Int), data.length - sizeof(Int)))
            
            let actionValue : UnsafePointer<Int> = UnsafePointer<Int>(header.bytes)
            let action : KWSPacketType = KWSPacketType.fromRaw(actionValue.memory)!
            
            self.delegate?.interfaceDidUpdate(interface: self, command: action, data: body)
            
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
