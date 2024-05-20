//
//  ContentView.swift
//  BLEBacgroundScanning
//
//  Created by Wasif Jameel on 14/05/2024.
//
//
//  ContentView.swift
//  BLEScanner
//
//  Created by Christian Möller on 02.01.23.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject private var bluetoothScanner = BluetoothScanner()
    @ObservedObject private var Notifications = NotificationManager()
    @State private var searchText = ""
    
    
    var body: some View {
        VStack {         
            // List of discovered peripherals filtered by search text
            List(bluetoothScanner.discoveredPeripherals ,id: \.peripheral.identifier)
                 { discoveredPeripheral in
                    VStack(alignment: .leading) {
                        Text(discoveredPeripheral.peripheral.name ?? "Unknown Device")
                        HStack {
                            Text("Distance: \(discoveredPeripheral.distance) m")
                            // Text("Distance: \(String(format: "%.2f", discoveredPeripheral.distance)) m")
                        }
                        HStack {
                            Text("TimeStamp: \(discoveredPeripheral.timestamp, style: .time)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack{
                            Text("Advertised Data: \(discoveredPeripheral.advertisedData)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack{
                            Text("Random: \(discoveredPeripheral.advertisedData)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
            }
            // Button for starting or stopping scanning
            Button(action: {
                if self.bluetoothScanner.isScanning {
                    self.bluetoothScanner.stopScan()
                    Notifications.scheduleNotification(title: "Stopped Scanning", body: "Scanning is stopped")
                } else {
                    self.bluetoothScanner.startScan()
                    Notifications.scheduleNotification(title: "Starting Scanning", body: "Scanning is running")
                }
            }) {
                if bluetoothScanner.isScanning {
                    Text("Stop Scanning")
                    
                } else {
                    Text("Scan for Devices")
                }
            }
            // Button looks cooler this way on iOS
            .padding()
            .background(bluetoothScanner.isScanning ? Color.red : Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(5.0)
            }.onAppear{
                Notifications.requestAuthorization();
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
