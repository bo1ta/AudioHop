//
//  NotificationManager.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 07.11.2024.
//

import UserNotifications
import Foundation
import Factory

final class NotificationManager: NSObject {
  @Injected(\.logger) private var logger: Logger

  func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] success, error in
      guard error == nil else {
        self?.logger.error(error!, message: "Error requesting authorization permissions")
        return
      }

      if success {
        UNUserNotificationCenter.current().delegate = self
        print("Notification permissions granted")
      } else {
        print("Notification permissions denied")
      }
    }
  }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .badge])
  }
}
