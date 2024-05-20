//
//  BLEScannerClass.swift
//  BLEBacgroundScanning
//
//  Created by Wasif Jameel on 14/05/2024.
//

import SwiftUI
import CoreBluetooth


struct DiscoveredPeripheral {
    // Struct to represent a discovered peripheral
    var peripheral: CBPeripheral
    var advertisedData: String
    var timestamp: Date
    var distance: Double

}

class BluetoothScanner: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var discoveredPeripherals = [DiscoveredPeripheral]()
    @Published var isScanning = false
    @ObservedObject private var Notifications = NotificationManager()

    var centralManager: CBCentralManager!
    // Set to store unique peripherals that have been discovered
    var discoveredPeripheralSet = Set<CBPeripheral>()
    var timer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        if centralManager.state == .poweredOn {
            // Set isScanning to true and clear the discovered peripherals list
            isScanning = true
            discoveredPeripherals.removeAll()
            discoveredPeripheralSet.removeAll()
            objectWillChange.send()

             let serviceUUIDs: [CBUUID] = [CBUUID(string: "37003700-8382-7243-3637-463827367373")]
            // let serviceUUIDs: [CBUUID] = [CBUUID(string: "181c")]
//            let serviceUUIDs: [CBUUID] = []
            // Start scanning for peripherals
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

            // Start a timer to stop and restart the scan every 2 seconds
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { [weak self] timer in
                self?.centralManager.stopScan()
                self?.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }
        }
    }

    func stopScan() {
        // Set isScanning to false and stop the timer
        isScanning = false
        timer?.invalidate()
        centralManager.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            //print("central.state is .unknown")
            stopScan()
        case .resetting:
            //print("central.state is .resetting")
            stopScan()
        case .unsupported:
            //print("central.state is .unsupported")
            stopScan()
        case .unauthorized:
            //print("central.state is .unauthorized")
            stopScan()
        case .poweredOff:
            //print("central.state is .poweredOff")
            stopScan()
        case .poweredOn:
            //print("central.state is .poweredOn")
            startScan()
        @unknown default:
            print("central.state is unknown")
        }
    }

   func removePeripheralAfter5secondsOfInactivityBasedOnTimeStamp() {
    let currentTime = Date()
    discoveredPeripherals.removeAll { peripheral in
        let timeDifference = currentTime.timeIntervalSince(peripheral.timestamp)
        return timeDifference > 30
    }
    objectWillChange.send()
}
    
    func RSSIToDistanceInMeter(_ RSSI:NSNumber)->Double{
        return pow(10, ((-69 - Double(truncating: RSSI)) - 40) / 20)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        let distance = RSSIToDistanceInMeter(RSSI)
        
        
        if(peripheral.name?.localizedCaseInsensitiveContains("") == true){
            print("peripheral \(peripheral)")
        }
        
    // Check if the peripheral has already been discovered
    if !discoveredPeripheralSet.contains(peripheral) {
        print("Adding new device")
        // Add the peripheral to the set of discovered peripherals
        discoveredPeripheralSet.insert(peripheral)

        // Create a DiscoveredPeripheral object and add it to the array of discovered peripherals

        let discoveredPeripheral = DiscoveredPeripheral(peripheral: peripheral, advertisedData: advertisementData.description, timestamp: Date(), distance: distance )

        discoveredPeripherals.append(discoveredPeripheral)

        Notifications.scheduleNotification(title: "New Beacon", body: "Discovered BTLR Beacon: \(peripheral.name ?? "Unknown Device") at distance \(distance) m")
        
        objectWillChange.send()
    }
        else{
            
            for i in 0..<discoveredPeripherals.count{
                if discoveredPeripherals[i].peripheral == peripheral{
                    
                    discoveredPeripherals[i].advertisedData = advertisementData.description
                    discoveredPeripherals[i].timestamp = Date()
                    discoveredPeripherals[i].distance = distance

                    objectWillChange.send()
                    break
                }
            }

            
        }
//        removePeripheralAfter5secondsOfInactivityBasedOnTimeStamp()
}
}
