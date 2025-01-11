//
//  NotificationManager.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 07.11.2024.
//

import Factory
import Foundation
import UserNotifications

// MARK: - UNNotificationWrapper

final class UNNotificationWrapper: NSObject {
  @Injected(\.logger) private var logger: Logger

  func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] success, error in
      guard error == nil else {
        self?.logger.error(error ?? NSError(domain: "UNNotificationWrapper", code: 100), message: "Error requesting authorization permissions")
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

// MARK: UNUserNotificationCenterDelegate

extension UNNotificationWrapper: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent _: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    completionHandler([.banner, .badge])
  }
}
