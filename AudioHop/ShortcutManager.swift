//
//  ShortcutManager.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import Combine
import CoreAudio
import Factory
import MASShortcut
import SwiftUI

// MARK: - ShortcutManager

final class ShortcutManager {
  enum Event {
    case shortcutUpdated(MASShortcut)
  }

  @Injected(\.audioManager) private var audioManager: AudioManager
  @Injected(\.logger) private var logger: Logger

  private let eventSubject = PassthroughSubject<Event, Never>()
  private let shortcutMonitor = MASShortcutMonitor.shared()
  private let dictionaryTransformer = MASDictionaryTransformer()

  var eventPublisher: AnyPublisher<Event, Never> {
    eventSubject.eraseToAnyPublisher()
  }

  func setupShortcuts() {
    shortcutMonitor?.unregisterAllShortcuts()

    let preferences = AudioDeviceStorage.loadDevices()
    preferences
      .compactMap { preference -> (AudioDeviceID, MASShortcut)? in
        guard
          let shortcutDictionary = preference.shortcut,
          let shortcut = shortcutFromDictionary(shortcutDictionary)
        else {
          return nil
        }

        return (preference.id, shortcut)
      }
      .forEach { deviceID, shortcut in
        addShortcut(shortcut, for: deviceID)
      }
  }

  func addShortcut(_ shortcut: MASShortcut, for deviceID: AudioDeviceID) {
    guard let shortcutMonitor else {
      logger.error(CustomError.invalidSDK, message: "Cannot find shortcut monitor")
      return
    }

    shortcutMonitor.register(shortcut, withAction: { [weak self] in
      guard self?.audioManager.setDefaultOutputDevice(deviceID: deviceID) == true else {
        self?.logger.error(CustomError.invalidDefaultDevice, message: "Error setting default output device for shortcut")
        return
      }
    })

    postShortcutUpdatedNotification(shortcut)
  }

  func removeShortcut(_ shortcut: MASShortcut) {
    shortcutMonitor?.unregisterShortcut(shortcut)
    postShortcutUpdatedNotification(shortcut)
  }

  func dictionaryFromShortcut(_ shortcut: MASShortcut) -> [String: Any]? {
    dictionaryTransformer.reverseTransformedValue(shortcut) as? [String: Any]
  }

  func shortcutFromDictionary(_ dictionary: [String: Any]) -> MASShortcut? {
    dictionaryTransformer.transformedValue(dictionary) as? MASShortcut
  }

  private func postShortcutUpdatedNotification(_ shortcut: MASShortcut) {
    eventSubject.send(.shortcutUpdated(shortcut))
  }
}

// MARK: ShortcutManager.CustomError

extension ShortcutManager {
  enum CustomError: Error {
    case invalidSDK
    case invalidDefaultDevice
  }
}
