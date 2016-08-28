//
//  ViewController.swift
//  BLEMi
//
//  Created by Hemal  on 30/07/16.
//  Copyright © 2016 Hemal . All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController1: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var Service1 :String! = "FEE0"
    var Service2 :String! = "FEE1"
    var Service3 :String! = "FEE7"
    var Service4 :String! = "1802"
    
    
    var titleLabel :UILabel!
    var statusLabel :UILabel!
    var tempLabel :UILabel!
    
    var centralManager :CBCentralManager!
    var sensorTagPeripheral :CBPeripheral!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        titleLabel = UILabel()
        titleLabel.text = "my sensorTag"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: 40)
        self.view.addSubview(titleLabel)
        
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.center
        statusLabel.text = "Loading...!"
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: 55, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        tempLabel = UILabel()
        tempLabel.text = "00.00"
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 72)
        tempLabel.sizeToFit()
        tempLabel.center = self.view.center
        self.view.addSubview(tempLabel)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn
        {
            central.scanForPeripherals(withServices: nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else
        {
            print("Bluetooth Switched off")
        }
    }
    
    private func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber)
    {
        let deviceName = "MI1A"
        let nameOfdeviceFound = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        print("didDiscoverPerifpheral = \(peripheral.name!)")
        
        /*
        if nameOfdeviceFound == deviceName
        {
            self.statusLabel.text = "Mi belt found"
            self.centralManager.stopScan()
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connect(peripheral, options: nil)
        }
        else
        {
            self.statusLabel.text = "belt not found"
        }
 */
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.statusLabel.text = "Discovering peripheral services"

        peripheral.discoverServices([CBUUID(string:Service4),CBUUID(string:Service3),CBUUID(string:Service2),CBUUID(string:Service1)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        self.statusLabel.text = "Looking at peripheral services"
        
        for service in self.sensorTagPeripheral.services!
        {
            let thisServices = service as CBService
            print("Discovered service: %@", service.uuid);
            do
            {
                peripheral.discoverCharacteristics([CBUUID(string:Service4),CBUUID(string:Service3),CBUUID(string:Service2),CBUUID(string:Service1)], for: thisServices)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
        self.statusLabel.text = "Enabling Service"
        

            if service.uuid == CBUUID(string:Service1)
            {
                print("Service 1")
            }
            else if service.uuid == CBUUID(string:Service2)
            {
                print("Service 2")
            }
            else if service.uuid == CBUUID(string:Service3)
            {
                print("Service 3")
            }
            else
            {
                print("Service 4")
            }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: NSError?)
    {
             self.statusLabel.text = "Connected"
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: NSError?)
    {
        if characteristic.isNotifying
        {
            
        }
    }
    
}

