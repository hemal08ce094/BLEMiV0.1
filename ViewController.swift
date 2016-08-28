//
//  ViewController.swift
//  BLEMi
//
//  Created by Hemal  on 28/08/16.
//  Copyright © 2016 Hemal . All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    
    var manager: CBCentralManager!
    var miBand: CBPeripheral!
 
    var Service1 :String! = "FEE0"
    var Service2 :String! = "FEE1"
    var Service3 :String! = "FEE7"
    var Service4 :String! = "1802"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("name : \(peripheral.name)")
        
        if (peripheral.name == "MI")
        {
            self.miBand = peripheral
            self.miBand.delegate = self
            manager.stopScan()
            manager.connect(self.miBand, options: nil)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
            for service in self.miBand.services!
            {
                peripheral.discoverCharacteristics(nil, for: service)
            }
     }
    
    
    @IBAction func refreshBLE(_ sender: AnyObject)
    {
        manager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charactertArray = service.characteristics as [CBCharacteristic]!
        {
            for cc in charactertArray
            {
                peripheral.setNotifyValue(true, for: cc)
                
                if cc.uuid.uuidString == "FF0F"{
                    let data: Data = "2".data(using: String.Encoding.utf8)!
                    peripheral.writeValue(data, for: cc, type: CBCharacteristicWriteType.withoutResponse)
                } else if cc.uuid.uuidString == "FF06" {
                    print("READING STEPS")
                    peripheral.readValue(for: cc)
                } else if cc.uuid.uuidString == "FF0C" {
                    print("READING BATTERY")
                    peripheral.readValue(for: cc)
                }
                else if cc.uuid.uuidString == "FF01" {
                    print("READING Info")
                    peripheral.readValue(for: cc)
                }
                
                
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if(characteristic.uuid.uuidString == "FF06") {
            let u16 = (characteristic.value! as NSData).bytes.bindMemory(to: Int.self, capacity: characteristic.value!.count).pointee
            print("\(u16) steps")
        self.lblSteps.text = "\(u16) steps"
        } else if(characteristic.uuid.uuidString == "FF0C") {
            var u16 = (characteristic.value! as NSData).bytes.bindMemory(to: Int32.self, capacity: characteristic.value!.count).pointee
            u16 =  u16 & 0xff
            self.lblBattery.text = "\(u16) % charged"
        }
        else if(characteristic.uuid.uuidString == "FF01") {
            var u16 = (characteristic.value! as NSData).bytes.bindMemory(to: Int8.self, capacity: characteristic.value!.count).pointee
            // u16 =  u16 & 0xff
            print("\(u16) device Info")
            //self.lblBattery.text = "\(u16) % device Info"
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
         peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
  
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var msg = ""
        switch (central.state)
        {
        case .poweredOff:
            msg = "powered off"
        case .poweredOn:
            msg = "powered on"
            manager.scanForPeripherals(withServices: nil, options: nil)
        default: break
        }
        print("State: \(msg)")
        
    }
}

