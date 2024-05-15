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
}

class BluetoothScanner: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var discoveredPeripherals = [DiscoveredPeripheral]()
    @Published var isScanning = false
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

            let serviceUUIDs: [CBUUID] = [CBUUID(string: "2e938fd0-6a61-11ed-a1eb-0242ac120002")]

            // Start scanning for peripherals
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

            // Start a timer to stop and restart the scan every 2 seconds
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    // Check if the peripheral has already been discovered
    if !discoveredPeripheralSet.contains(peripheral) {
        // Add the peripheral to the set of discovered peripherals
        discoveredPeripheralSet.insert(peripheral)

        // Create a DiscoveredPeripheral object and add it to the array of discovered peripherals

        let finalAdvertisementData="RSSI: \(RSSI) dBm\n" + "Distance: \(pow(10, ((-69 - Double(truncating: RSSI)) - 40) / 20)) m\n" + "Timestamp: \(Date())\n" + advertisementData.description
        let discoveredPeripheral = DiscoveredPeripheral(peripheral: peripheral, advertisedData: finalAdvertisementData)
        discoveredPeripherals.append(discoveredPeripheral)

        // Notify observers that the discoveredPeripherals array has changed
        objectWillChange.send()
    }
}
}
