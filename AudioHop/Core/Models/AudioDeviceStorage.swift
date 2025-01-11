//
//  AudioDeviceStorage.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import Foundation

enum AudioDeviceStorage {
  private static let defaults = UserDefaults.standard
  private static let key = "audioDevicePreferences"

  static func saveDevices(_ devices: [AudioDevice]) {
    if let encoded = try? JSONEncoder().encode(devices) {
      defaults.set(encoded, forKey: key)
    }
  }

  static func loadDevices() -> [AudioDevice] {
    guard
      let data = defaults.data(forKey: key),
      let preferences = try? JSONDecoder().decode([AudioDevice].self, from: data)
    else {
      return []
    }
    return preferences
  }
}
