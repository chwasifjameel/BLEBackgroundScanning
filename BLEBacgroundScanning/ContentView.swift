//
//  ContentView.swift
//  BLEBacgroundScanning
//
//  Created by Wasif Jameel on 14/05/2024.
//
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
//    @ObservedObject private var bluetoothScanner = BluetoothScanner()
    @ObservedObject private var Notifications = NotificationManager()
    @ObservedObject private var BManager = BeaconManager()
    @State private var searchText = ""
    
    
    var body: some View {
        VStack {         
            // List of discovered peripherals filtered by search text
            List(BManager.discoveredBeacons ,id: \.identifier)
                 { beacon in
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Unique ID")
                            Text( beacon.identifier ?? "Unknown Device")
                        }.font(Font.caption)
                        HStack {
                            Text("Distance: \(beacon.distance)")
                            // Text("Distance: \(String(format: "%.2f", discoveredPeripheral.distance)) m")
                        }
                        HStack {
                            Text("Major: \(beacon.major)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack{
                            Text("Minor: \(beacon.minor)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack{
                            Text("RSSI: \(beacon.rssi)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack{
                            Text("Proximity: \(beacon.proximity)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack{
                            Text("Timestamp: \(beacon.timestamp)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
            }
            // Button for starting or stopping scanning
            Button(action: {
                if self.BManager.isScanning {
                    BManager.stopScanning()
                } else {
                    BManager.startScanning()
                }
            }) {
                if BManager.isScanning {
                    Text("Stop Scanning")
                } else {
                    Text("Scan for Devices")
                }
            }
            // Button looks cooler this way on iOS
            .padding()
            .background(BManager.isScanning ? Color.red : Color.blue)
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
