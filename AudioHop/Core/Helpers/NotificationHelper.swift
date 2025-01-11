//
//  NotificationHelper.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import UserNotifications

struct NotificationHelper {
  static func showNotification(with message: String) {
    let content = UNMutableNotificationContent()
    content.title = "Audio Hop"
    content.body = message
    let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(notification)
  }
}
