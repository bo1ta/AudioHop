//
//  AudioDeviceStore.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 12.11.2024.
//

import AudioToolbox
import Combine
import Factory
import Foundation

final class AudioDeviceStore {
  @Injected(\.audioManager) private var audioManager
  @Injected(\.logger) private var logger
  @Injected(\.shortcutManager) private var shortcutManager
  @Injected(\.defaultDeviceListener) private var defaultDeviceListener

  private(set) var audioDevices: [AudioDevice] = []
  private var cancellables: Set<AnyCancellable> = []

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(reloadPreferences),
      name: .onUpdateFavoriteDevices,
      object: nil)

    shortcutManager.eventPublisher
      .sink { [weak self] _ in
        self?.reloadPreferences()
      }
      .store(in: &cancellables)

    defaultDeviceListener.didChangeDefaultDevice
      .sink { [weak self] audioDeviceID in
        self?.updateDefaultDevice(audioDeviceID)
      }
      .store(in: &cancellables)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func initialLoad() {
    let storedDevices = loadStoredDevices()
    let currentDevices = audioManager.getOutputDevices()
    audioDevices = mergeDevices(currentDevices: currentDevices, storedDevices: storedDevices)
  }

  private func mergeDevices(currentDevices: [AudioDevice], storedDevices: [AudioDevice]) -> [AudioDevice] {
    currentDevices.map { currentDevice in
      if let storedDevice = storedDevices.first(where: { $0.id == currentDevice.id }) {
        var updatedDevice = currentDevice
        updatedDevice.isFavorite = storedDevice.isFavorite
        updatedDevice.shortcut = storedDevice.shortcut
        return updatedDevice
      }

      return currentDevice
    }
  }

  @objc
  private func reloadPreferences() {
    let storedDevices = self.loadStoredDevices()

    self.audioDevices = self.audioDevices.map { currentDevice in
      if let storedDevice = storedDevices.first(where: { $0.id == currentDevice.id }) {
        var updatedDevice = currentDevice
        updatedDevice.isFavorite = storedDevice.isFavorite
        updatedDevice.shortcut = storedDevice.shortcut
        return updatedDevice
      }

      return currentDevice
    }
  }

  private func loadStoredDevices() -> [AudioDevice] {
    AudioDeviceStorage.loadDevices()
  }

  private func reloadDevices() {
    audioDevices = audioManager.getOutputDevices()
  }

  func getDefaultDevice() -> AudioDevice? {
    audioDevices.first { $0.isDefault }
  }

  func getDeviceByID(_ id: AudioDeviceID) -> AudioDevice? {
    audioDevices.first { $0.id == id }
  }

  func getShowableDevices() -> [AudioDevice] {
    var devicesToShow = audioDevices.filter(\.isFavorite)
    if let defaultDevice = getDefaultDevice(), !devicesToShow.contains(where: { $0.id == defaultDevice.id }) {
      devicesToShow.insert(defaultDevice, at: 0)
    }
    return devicesToShow
  }

  func getShortcutKeyCodeStringForDevice(_ device: AudioDevice) -> String {
    guard
      let device = audioDevices.first(where: { $0.id == device.id }),
      let shortcutDictionary = device.shortcut
    else { return "" }

    return shortcutManager.shortcutFromDictionary(shortcutDictionary)?.keyCodeString ?? ""
  }

  func switchToNextOutput() -> AudioDevice? {
    var devicesToUse = audioDevices.filter(\.isFavorite)
    if
      let defaultDevice = getDefaultDevice(),
      !devicesToUse.contains(where: { $0.id == defaultDevice.id })
    {
      devicesToUse.insert(defaultDevice, at: 0)
    }

    guard
      !devicesToUse.isEmpty,
      let currentDefault = devicesToUse.first(where: { $0.isDefault }),
      let currentIndex = devicesToUse.firstIndex(where: { $0.id == currentDefault.id })
    else {
      return nil
    }

    let nextIndex = (currentIndex + 1) % devicesToUse.count
    let nextDevice = devicesToUse[nextIndex]

    return audioManager.setDefaultOutputDevice(deviceID: nextDevice.id) ? nextDevice : nil
  }

  @discardableResult
  func setDefaultOutput(_ device: AudioDevice) -> Bool {
    audioManager.setDefaultOutputDevice(deviceID: device.id)
  }

  private func resetDefaultDevice() {
    audioDevices = audioDevices.map {
      var copy = $0
      copy.isDefault = false
      return copy
    }
  }

  private func updateDefaultDevice(_ audioDeviceID: AudioDeviceID) {
    guard let firstIndex = audioDevices.map({ $0.id }).firstIndex(of: audioDeviceID) else {
      logger.warning("Cannot find deviceID in notification userInfo")
      reloadDevices()
      return
    }

    resetDefaultDevice()
    audioDevices[firstIndex].isDefault = true
  }
}
