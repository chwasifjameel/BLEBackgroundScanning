//
//  NotificationClass.swift
//  BLEBacgroundScanning
//
//  Created by Wasif Jameel on 15/05/2024.
//

import UserNotifications

class NotificationManager: ObservableObject {
    let notificationCenter: UNUserNotificationCenter

    init() {
        notificationCenter = UNUserNotificationCenter.current()
    }

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                // Handle the error here.
                print("Error: \(error)")
            }
            // Enable or disable features based on the authorization.
        }
    }

    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                // Handle the error here.
                print("Error: \(error)")
            }
        }
    }
}
