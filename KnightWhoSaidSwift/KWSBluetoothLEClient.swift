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
    private var transferService : CBMutableService!
    private var readCharacteristic : CBMutableCharacteristic!
    private var writeCharacteristic : CBMutableCharacteristic!
    private var serviceUUID = CBUUID(string: kKWServiceUUID)
    
    internal var recivedData : NSData? = nil
    internal var sendedData : NSData? = nil
    
    override init(ownerController : UIViewController, delegate: KWSBlueToothLEDelegate) {
        
        super.init(ownerController: ownerController, delegate: delegate)
        
        self.peripheralQueue = dispatch_queue_create("com.mp.devs.kwss.client", nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: self.peripheralQueue)
    }
    
    override func sendCommand(command command: KWSPacketType, data: NSData?) {
    
        if !interfaceConnected {
        
            return
        }
        
        var header : Int8 = command.rawValue
        let dataToSend : NSMutableData = NSMutableData(bytes: &header, length: sizeof(Int8))
        
        if let data = data {
        
            dataToSend.appendData(data)
        }
        
        if dataToSend.length > kKWSMaxPacketSize {
            
            print("Error data packet to long!")
            
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
        
        var packet : Int8 = KWSPacketType.Disconnect.rawValue
        self.sendedData = NSData(bytes: &packet, length: sizeof(Int8))
        
        let killSignalSend : Bool = self.peripheralManager.updateValue( self.sendedData!,
                                                     forCharacteristic: self.readCharacteristic,
                                                  onSubscribedCentrals: nil)
        
        if killSignalSend {
        
            self.peripheralManager.stopAdvertising()
        }
    }
    
    //MARK: CBPeripheralManagerDelegate method implementation
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
    
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
        
            return;
        }
        
        print("self.peripheralManager powered on.")
        
        self.readCharacteristic = CBMutableCharacteristic(  type: CBUUID(string: kKWSReadUUID),
                                                      properties: CBCharacteristicProperties.Notify,
                                                           value: nil,
                                                     permissions: CBAttributePermissions.Readable)
        
        self.writeCharacteristic = CBMutableCharacteristic( type: CBUUID(string: kKWSWriteUUID),
                                                      properties: CBCharacteristicProperties.Write,
                                                           value: nil,
                                                     permissions: CBAttributePermissions.Writeable)
        
        self.transferService = CBMutableService(type: serviceUUID, primary: true)
        
        var characteristics = [CBMutableCharacteristic]()
            characteristics.append(self.readCharacteristic)
            characteristics.append(self.writeCharacteristic)
        
        self.transferService.characteristics = characteristics
        
        self.peripheralManager.addService(self.transferService)
        
        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        
        dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
            
            self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [self.serviceUUID]])
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
    
        print("advertise started on perihperal")
        
        if let error = error {
        
            print("\(error)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        
        print("read request: \(request)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        if requests.count == 0 {
            
            return;
        }
        
        for req in requests as [CBATTRequest] {
        
            let data : NSData = req.value!
            let header : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int8)))
            
            let remainingVal = data.length - sizeof(Int8)
            
            var body : NSData? = nil
            
            if remainingVal > 0 {
            
                body = data.subdataWithRange(NSMakeRange(sizeof(Int8), remainingVal))
            }
            
            let actionValue : UnsafePointer<Int8> = UnsafePointer<Int8>(header.bytes)
            let action : KWSPacketType = KWSPacketType(rawValue: actionValue.memory)!
            
            self.delegate?.interfaceDidUpdate(interface: self, command: action, data: body)
            
            self.peripheralManager.respondToRequest(req, withResult: CBATTError.Success)
        }
    }
    
    func peripheralManager(              peripheral: CBPeripheralManager,
                                            central: CBCentral,
        didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        
        print("Central subscribed to characteristic")
            
        //start sending data here 
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
            AudioServicesPlaySystemSound(1254)
        })

        self.interfaceConnected = true
        self.sendCommand(command: .Connect, data: nil)
    }
    
    func peripheralManager(                  peripheral: CBPeripheralManager,
                                                central: CBCentral,
        didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        
        self.interfaceConnected = false
        self.delegate?.interfaceDidUpdate(interface: self, command: .Disconnect, data: nil)
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        
        print("ready to send next packet")
    }
}
