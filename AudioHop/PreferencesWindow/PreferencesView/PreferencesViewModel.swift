//
//  PreferencesViewModel.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import SwiftUI
import AudioToolbox
import Combine
import MASShortcut
import ServiceManagement
import Factory

@Observable
@MainActor
class PreferencesViewModel {

  @ObservationIgnored
  @Injected(\.logger) private var logger: Logger

  @ObservationIgnored
  @Injected(\.audioManager) private var audioManager: AudioManager

  @ObservationIgnored
  @Injected(\.deviceStore) private var deviceStore: AudioDeviceStore

  @ObservationIgnored
  @Injected(\.shortcutManager) private var shortcutManager: ShortcutManager

  @ObservationIgnored
  @Injected(\.defaultDeviceListener) private var defaultDeviceListener

  private var cancellables: Set<AnyCancellable> = []

  var launchAtLogin = false
  var devices: [AudioDevice] = []

  init() {
    loadDevices()

    defaultDeviceListener.didChangeDefaultDevice
      .receive(on: DispatchQueue.main)
      .sink { [weak self] audioDeviceID in
        self?.updateDefaultDevice(audioDeviceID)
      }
      .store(in: &cancellables)
  }

  func loadDevices() {
    devices = deviceStore.audioDevices
  }

  @objc private func updateDefaultDevice(_ audioDeviceID: AudioDeviceID) {
    guard
      let firstIndex = devices.firstIndex(where: { $0.id == audioDeviceID })
    else {
      logger.error(CustomError.invalidDevice, message: "Could not update default device")
      return
    }

    devices = deviceStore.audioDevices
  }

  func getLaunchAtLoginState() async -> Bool {
    return SMAppService.mainApp.status == .enabled
  }

  func toggleLaunchAtLogin() {
    let service = SMAppService.mainApp
    if service.status == .enabled {
      do {
        try service.unregister()
        launchAtLogin = false
      } catch {
        logger.error(CustomError.failedToSetLaunchAtLogin, message: "Error unregistering app service at login")
      }
    } else {
      do {
        try service.register()
        launchAtLogin = true
      } catch {
        logger.error(CustomError.failedToSetLaunchAtLogin, message: "Error registering app service at login")
      }
    }
  }

  func setShortcut(_ shortcut: MASShortcut?, for deviceID: AudioDeviceID) {
    guard
      let shortcut,
      let shortcutDictionary = shortcutManager.dictionaryFromShortcut(shortcut),
      let index = devices.firstIndex(where: { $0.id == deviceID })
    else {
      removeShortcut(for: deviceID)
      return
    }

    devices[index].shortcut = shortcutDictionary
    savePreferences()
    shortcutManager.addShortcut(shortcut, for: deviceID)
  }

  func getShortcut(for deviceID: AudioDeviceID) -> MASShortcut? {
    guard let shortcutDictionary = devices.first(where: { $0.id == deviceID })?.shortcut else {
      return nil
    }
    return shortcutManager.shortcutFromDictionary(shortcutDictionary)
  }

  func removeShortcut(for deviceID: AudioDeviceID) {
    guard
      let index = devices.firstIndex(where: { $0.id == deviceID }),
      let dictionaryShortcut = devices[index].shortcut,
      let shortcut = shortcutManager.shortcutFromDictionary(dictionaryShortcut)
    else {
      logger.error(CustomError.invalidShortcut, message: "Cannot remove invalid shortcut")
      return
    }

    devices[index].shortcut = nil
    savePreferences()
    shortcutManager.removeShortcut(shortcut)
  }

  func toggleFavorite(for deviceID: AudioDeviceID) {
    guard let index = devices.firstIndex(where: { $0.id == deviceID }) else { return }

    devices[index].isFavorite.toggle()
    savePreferences()
    sendFavoritesUpdatedNotification()
  }

  private func savePreferences() {
    AudioDeviceStorage.saveDevices(devices)
  }

  private func sendFavoritesUpdatedNotification() {
    NotificationCenter.default.post(name: .onUpdateFavoriteDevices, object: nil)
  }

  func isFavorite(_ deviceID: AudioDeviceID) -> Bool {
    return devices.first(where: { $0.id == deviceID })?.isFavorite ?? false
  }
}

extension PreferencesViewModel {
  enum CustomError: Error {
    case invalidDevice
    case failedToSetLaunchAtLogin
    case invalidShortcut
  }
}
