import CoreBluetooth
import CoreLocation
import UserNotifications


struct IBeacon{
var uuid: String
var major: Int
var minor:Int
var distance: Double
var rssi:Int
var identifier:String
var proximity:Int
var timestamp:Date
}

@objc(BeaconManager)
class BeaconManager: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate, ObservableObject
{
    
    
    private var locationManager: CLLocationManager!
    private var beaconRegion: CLBeaconRegion!
    private var centralManager: CBCentralManager!
    @Published var discoveredBeacons: [IBeacon] = []
    @Published var isScanning:Bool = false
    
    func statusToString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown"
        }
    }

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        startScanning()
    }

    
    // Method for sending local notifications
    func sendLocalNotification(with message: String) {
        let content = UNMutableNotificationContent()
        content.title = message // Notification title
        content.body = "This is a region event" // Notification text
        content.sound = .default // Notification sound
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil) // Create a notification request
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil) // Adding a request to the notification center
    }
    
    // Start scanning beacons with the given UUID
    @objc func startScanning() {
        isScanning=true;
        // Request permission to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            granted, error in
            
            if granted {
                print("Notifications allowed")
            } else {
                print("Notifications not allowed")
            }
        }
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager() // Initialize CLLocationManager
            self.locationManager.delegate = self // Setting the delegate
            self.locationManager.requestAlwaysAuthorization() // Request for permanent access to geolocation
            
            // Check and set settings for background scanning
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            
            let uuid = UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")! // Convert UUID string to UUID
            let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid) // Create a constraint for the beacon
            self.beaconRegion = CLBeaconRegion(
                beaconIdentityConstraint: beaconConstraint, identifier: "BeaconManagerRegion") // Initialize the beacon region
            self.beaconRegion.notifyOnEntry = true // Notification when entering a region
            self.beaconRegion.notifyOnExit = true // Notification when exiting a region
            
            self.locationManager.startMonitoring(for: self.beaconRegion) // Start monitoring the region
            self.locationManager.startRangingBeacons(in: self.beaconRegion) // Start determining the distance to beacons in the region
        }
    }
    
    // Stop scanning beacons
    @objc func stopScanning() {
        isScanning = false;
        if let beaconRegion = self.beaconRegion {
            self.locationManager.stopMonitoring(for: beaconRegion) // Stop monitoring the region
            self.locationManager.stopRangingBeacons(in: beaconRegion) // Stop determining the distance to beacons
            self.beaconRegion = nil // Reset the beacon region
            self.locationManager = nil // Reset CLLocationManager
        }
    }
    
    // Initialize the Bluetooth manager
    @objc func initializeBluetoothManager() {
        centralManager = CBCentralManager(
            delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
    
    // Handle Bluetooth state changes
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg = ""
        switch central.state {
        case .unknown: msg = "unknown"
        case .resetting: msg = "resetting"
        case .unsupported: msg = "unsupported"
        case .unauthorized: msg = "unauthorized"
        case .poweredOff: msg = "poweredOff"
        case .poweredOn: msg = "poweredOn"
        @unknown default: msg = "unknown"
        }
        print("central===>",msg)
        //     bridge.eventDispatcher().sendAppEvent(withName: "onBluetoothStateChanged", body: ["state": msg]) // Send Bluetooth state change event to React Native
    }
    
    // Request for permanent access to geolocation
    @objc func requestAlwaysAuthorization() {
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let status = locationManager.authorizationStatus
        
        let statusString = statusToString(status)
        print("status===>",statusString)
        //     resolve(["status": statusString])
    }
    
    // Request for access to geolocation when using the application
    @objc func requestWhenInUseAuthorization() {
        
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        let statusString = statusToString(status)
        //     resolve(["status": statusString])
    }
    
    // Get the current geolocation permission status
//    @objc func getAuthorizationStatus(
//        _ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock
//    ) {
//        let status = CLLocationManager.authorizationStatus()
//        resolve(statusToString(status))
//    }
    
    // Handling region entry and region exit events
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Region====>\(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            sendLocalNotification(with: "Entered region: \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Region------->\(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            sendLocalNotification(with: "Exit region: \(region.identifier)")
        }
    }
    
    // Handle detection of beacons in the region
    func locationManager(
        _ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion
    ) {
        print("beacons=====>",beacons)
        sendLocalNotification(with: "New Beacon is scanned")
        
        let beaconArray = beacons.map { beacon -> IBeacon in
            return IBeacon(uuid: beacon.uuid.uuidString, 
            major: beacon.major.intValue, minor: beacon.minor.intValue, 
                           distance: beacon.accuracy, rssi: beacon.rssi, identifier: beacon.uuid.uuidString+beacon.major.stringValue+beacon.minor.stringValue,proximity: beacon.proximity.rawValue, timestamp:beacon.timestamp )
        }
        discoveredBeacons = beaconArray
    }
    }

