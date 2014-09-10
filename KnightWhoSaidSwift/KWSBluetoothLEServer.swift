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
    private var readCharacteristic : CBCharacteristic? = nil
    private var writeCharacteristic : CBCharacteristic? = nil
    
    override init(ownerController : UIViewController, delegate: KWSBlueToothLEDelegate) {
        
        super.init(ownerController: ownerController, delegate: delegate)
        
        self.centralQueue = dispatch_queue_create("com.mp.devs.kwss.server", nil)
        self.centralManager = CBCentralManager(delegate: self, queue: self.centralQueue)
    }
    
    override func sendCommand(#command: KWSPacketType, data: NSData!){
        
        var header : Int = command.toRaw()
        var dataToSend : NSMutableData = NSMutableData(bytes: &header, length: sizeof(Int))
            dataToSend.appendData(data)
        
        if dataToSend.length > kKWSMaxPacketSize {
            
            println("Error data packet to long!")
            
            return
        }
        
        if let discoveredPeripheral = self.discoveredPeripheral {
        
            discoveredPeripheral.writeValue( dataToSend,
                          forCharacteristic: self.writeCharacteristic,
                                       type: .WithoutResponse)
        }
    }
  
    //MARK: Central methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        if central.state != .PoweredOn {
        
            return
        }
        
        self.scan()
    }
    
    func scan() {
    
        println("Scaning started")
        
        let service : [AnyObject] = [CBUUID.UUIDWithString(kKWServiceUUID)]
        let options : [String:NSValue] = [CBCentralManagerScanOptionAllowDuplicatesKey : NSValue(nonretainedObject: 1)]
        
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
            
            if discoveredPeripheral.services == nil {
             
                return
            }
            
            for service in discoveredPeripheral.services {
                
                var currentService : CBService = service as CBService
                
                if currentService.characteristics == nil {
                    
                    continue
                }
                
                for characteristic in currentService.characteristics {
                
                    var currentCharacteristic : CBCharacteristic = characteristic as CBCharacteristic
                    
                    if currentCharacteristic.UUID != CBUUID.UUIDWithString(kKWServiceUUID) {
                    
                        continue
                    }
                    
                    if currentCharacteristic.isNotifying {
                        
                        discoveredPeripheral.setNotifyValue(false, forCharacteristic: currentCharacteristic)
                        return
                    }
                }
            }
        
            self.centralManager.cancelPeripheralConnection(discoveredPeripheral)
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if (RSSI.integerValue > -5) || (RSSI.integerValue < -35) {
        
            return;
        }
        
        println("discovered at: \(RSSI) name: \(peripheral.name)")
        
        if self.discoveredPeripheral != peripheral {
        
            self.discoveredPeripheral = peripheral
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        println("failed to connect: \(peripheral.name) error: \(error.localizedDescription)")
        
        self.cleanup()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        println("peripheral connected")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            AudioServicesPlaySystemSound(1254)
            
            //add some player here
            
            central.stopScan()
            peripheral.delegate = self
            peripheral.discoverServices([CBUUID.UUIDWithString(kKWServiceUUID)])
            
        })
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        if (error != nil) {
        
            println("error while discovering services: \(error.localizedDescription)")
            self.cleanup()
            return
        }
        
        for service in peripheral.services {
        
            let characteristic : [AnyObject] = [CBUUID.UUIDWithString(kKWSReadUUID), CBUUID.UUIDWithString(kKWSWriteUUID)]
            
            peripheral.discoverCharacteristics(characteristic, forService: service as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if (error != nil) {
            
            println("error while discovering characteristic: \(error.localizedDescription)")
            self.cleanup()
            return
        }
        
        for characteristic in service.characteristics {
        
            if characteristic.UUID == CBUUID.UUIDWithString(kKWSReadUUID) {
            
                self.readCharacteristic = characteristic as? CBCharacteristic
                peripheral.setNotifyValue(true, forCharacteristic: self.readCharacteristic)
            }
            else if characteristic.UUID == CBUUID.UUIDWithString(kKWSWriteUUID) {
            
                self.writeCharacteristic = characteristic as? CBCharacteristic
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if (error != nil) {
            println("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            return
        }
        
        let data : NSData = characteristic.value
        let header : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int)))
        let body : NSData = data.subdataWithRange(NSMakeRange(sizeof(Int), data.length - sizeof(Int)))
        
        let actionValue : UnsafePointer<Int> = UnsafePointer<Int>(header.bytes)
        let action : KWSPacketType = KWSPacketType.fromRaw(actionValue.memory)!
        
        self.delegate?.interfaceDidUpdate(interface: self, command: action, data: body)
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if (error != nil) {
            
            println("didWriteValueForCharacteristic error: \(error.localizedDescription)")
        
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
                        handler: { (action: UIAlertAction!) -> Void in
                            
                            KWSAlertController.dismissViewControllerAnimated(true, completion: nil)
                            
                        })
                    
                    KWSAlertController.addAction(okAction)
                    
                    presentVC.presentViewController(KWSAlertController, animated: true, completion: nil)
                }
    
            })
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForDescriptor descriptor: CBDescriptor!, error: NSError!) {
        
        if (error != nil) {
        
            println("peripheraldidWriteValueForDescriptorError: \(error.localizedDescription)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if (error != nil) {

            println("error while changing notification state: \(error.localizedDescription)")
        }
        
        if characteristic.UUID != CBUUID.UUIDWithString(kKWServiceUUID) {
            
            return
        }
        
        if characteristic.isNotifying {
        
            println("notification began on \(characteristic)")
        }
        else {
        
            println("notification stopped on \(characteristic)")
        }
        
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
     
        println("peripheral disconnected")
        self.discoveredPeripheral = nil
        self.scan()
    }
    
}
