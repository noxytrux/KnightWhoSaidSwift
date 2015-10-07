//
//  KWSBluetoothLEServer.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 01.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import CoreBluetooth
import AudioToolbox

class KWSBluetoothLEServer: KWSBluetoothLEInterface,
//DELEGATE
CBCentralManagerDelegate,
CBPeripheralDelegate {
   
    private let kKWSBTLEBlockCode = 14
    
    private var centralManager : CBCentralManager!
    private var centralQueue : dispatch_queue_t!
    private var discoveredPeripheral : CBPeripheral? = nil
    private var readCharacteristic : CBCharacteristic!
    private var writeCharacteristic : CBCharacteristic!
    
    override init(ownerController : UIViewController, delegate: KWSBlueToothLEDelegate) {
        
        super.init(ownerController: ownerController, delegate: delegate)
        
        self.centralQueue = dispatch_queue_create("com.mp.devs.kwss.server", nil)
        self.centralManager = CBCentralManager(delegate: self, queue: self.centralQueue)
    }
    
    override func sendCommand(command command: KWSPacketType, data: NSData?){
        
        if !interfaceConnected {
            
            return
        }

        //DO NOT USE Int -> vary on platform!
        var header : Int8 = command.rawValue
        let dataToSend : NSMutableData = NSMutableData(bytes: &header, length: sizeof(Int8))
        
        if let data = data {
            
            dataToSend.appendData(data)
        }
        
        if dataToSend.length > kKWSMaxPacketSize {
            
            print("Error data packet to long!")
            
            return
        }
        
        if let discoveredPeripheral = self.discoveredPeripheral {
        
            discoveredPeripheral.writeValue( dataToSend,
                          forCharacteristic: self.writeCharacteristic,
                                       type: .WithResponse)
        }
    }
  
    //MARK: Central methods
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        if central.state != .PoweredOn {
        
            return
        }
        
        self.scan()
    }
    
    func scan() {
    
        print("Scaning started")
        
        let service : [CBUUID] = [CBUUID(string: kKWServiceUUID)]
        let options : [String:NSNumber] = [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true)]
        
        self.centralManager.scanForPeripheralsWithServices(service, options: options)
    }
    
    func cleanup() {
        //funny: Compile error ?! SEG FAULT 11
        
//        if self.discoveredPeripheral?.state == .Disconnected {
//            
//            return
//        }
        
        if let discoveredPeripheral = self.discoveredPeripheral {
            
            if discoveredPeripheral.state == .Disconnected {
                
                return
            }
            
            guard let _ = discoveredPeripheral.services else {
             
                return
            }
            
            if let serives = discoveredPeripheral.services {
            
                for service in serives {
                    
                    let currentService: CBService = service as CBService
                    
                    if currentService.characteristics == nil {
                        
                        continue
                    }
                    
                    for characteristic in currentService.characteristics! {
                        
                        let currentCharacteristic: CBCharacteristic = characteristic as CBCharacteristic
                        
                        if currentCharacteristic.UUID != CBUUID(string: kKWServiceUUID) {
                            
                            continue
                        }
                        
                        if currentCharacteristic.isNotifying {
                            
                            discoveredPeripheral.setNotifyValue(false, forCharacteristic: currentCharacteristic)
                            return
                        }
                    }
                }
            }
            
            self.centralManager.cancelPeripheralConnection(discoveredPeripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if (RSSI.integerValue > -5) || (RSSI.integerValue < -35) {
        
            return;
        }
        
        print("discovered at: \(RSSI) name: \(peripheral.name)")
        
        if self.discoveredPeripheral != peripheral {
        
            self.discoveredPeripheral = peripheral
            
            let options : [String:NSNumber] = [CBConnectPeripheralOptionNotifyOnConnectionKey : NSNumber(bool: true)]
            self.centralManager.connectPeripheral(peripheral, options: options)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        if let error = error {
        
            print("failed to connect: \(peripheral.name) error: \(error.localizedDescription)")
        }
        
        self.cleanup()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("peripheral connected")
        
        central.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: kKWServiceUUID)])
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            AudioServicesPlaySystemSound(1254)
        })
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if let error = error {
        
            print("error while discovering services: \(error.localizedDescription)")
            self.cleanup()
            return
        }
        
        for service in peripheral.services! {
        
            let characteristic: [CBUUID] = [CBUUID(string: kKWSReadUUID), CBUUID(string: kKWSWriteUUID)]
            
            peripheral.discoverCharacteristics(characteristic, forService: service as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if let error = error {
            
            print("error while discovering characteristic: \(error.localizedDescription)")
            self.cleanup()
            return
        }
        
        for characteristic in service.characteristics! {
        
            if characteristic.UUID == CBUUID(string: kKWSReadUUID) {
            
                self.readCharacteristic = characteristic
                peripheral.setNotifyValue(true, forCharacteristic: self.readCharacteristic)
            }
            else if characteristic.UUID == CBUUID(string: kKWSWriteUUID) {
            
                self.writeCharacteristic = characteristic
            }
        }

        print("discovered Characteristics")
        
        self.interfaceConnected = true

        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        
        dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
            
            self.sendCommand(command: .Connect, data: nil)
        }

    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let error = error {
            print("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            return
        }
        
        let data : NSData = characteristic.value!
        let header : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int8)))
        
        let remainingVal = data.length - sizeof(Int8)
        var body : NSData? = nil
        
        if remainingVal > 0 {
            
            body = data.subdataWithRange(NSMakeRange(sizeof(Int8), remainingVal))
        }

        let actionValue : UnsafePointer<Int8> = UnsafePointer<Int8>(header.bytes)
        let action : KWSPacketType = KWSPacketType(rawValue: actionValue.memory)!
        
        self.delegate?.interfaceDidUpdate(interface: self, command: action, data: body)
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let error = error {
            
            print("didWriteValueForCharacteristic error: \(error.localizedDescription)")
        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if error.code != self.kKWSBTLEBlockCode {
                    return
                }
                
                if let presentVC = self.ownerViewController {
                    
                    let KWSAlertController = UIAlertController( title: NSLocalizedString("Error", comment: ""),
                        message: error.localizedDescription,
                        preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                        style: .Cancel,
                        handler: { (action: UIAlertAction) -> Void in
                            
                            KWSAlertController.dismissViewControllerAnimated(true, completion: nil)
                            
                        })
                    
                    KWSAlertController.addAction(okAction)
                    
                    presentVC.presentViewController(KWSAlertController, animated: true, completion: nil)
                }
    
            })
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        
        if let error = error {
        
            print("peripheraldidWriteValueForDescriptorError: \(error.localizedDescription)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let error = error {

            print("error while changing notification state: \(error.localizedDescription)")
        }
        
        if characteristic.UUID != CBUUID(string: kKWServiceUUID) {
            
            return
        }
        
        if characteristic.isNotifying {
        
            print("notification began on \(characteristic)")
            
        }
        else {
        
            print("notification stopped on \(characteristic)")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
        
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
     
        print("peripheral disconnected")
        self.interfaceConnected = false
        self.discoveredPeripheral = nil
        self.scan()
        
        self.delegate?.interfaceDidUpdate(interface: self, command: .Disconnect, data: nil)
    }
    
}
