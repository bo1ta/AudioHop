//
//  StatusBarManager.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 07.11.2024.
//

import AppKit
import AudioToolbox
import Cocoa
import Combine
import Factory
import Foundation

// MARK: - StatusBarManagerDelegate

protocol StatusBarManagerDelegate: AnyObject {
  func didPressPreferences()
  func didPressHelp()
}

// MARK: - StatusBarManager

final class StatusBarManager {
  @Injected(\.logger) private var logger
  @Injected(\.shortcutManager) private var shortcutManager
  @Injected(\.deviceStore) private var deviceStore: AudioDeviceStore
  @Injected(\.defaultDeviceListener) private var defaultDeviceListener

  private var statusItem: NSStatusItem
  private var deviceMenu: NSMenu?
  private var cancellables: Set<AnyCancellable> = []

  weak var delegate: StatusBarManagerDelegate?

  init() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    setupObservers()
  }

  func setupStatusButton() {
    guard let button = statusItem.button, let defaultDevice = deviceStore.getDefaultDevice() else {
      return
    }

    button.image = makeBarIcon(for: defaultDevice.outputType)
    button.target = self
    button.action = #selector(toggleAudioOutput)
    button.sendAction(on: [.leftMouseUp, .rightMouseUp])
  }

  private func setupObservers() {
    defaultDeviceListener.didChangeDefaultDevice
      .receive(on: DispatchQueue.main)
      .sink { [weak self] audioDeviceID in
        self?.updateMenuBarIcon(audioDeviceID)
      }
      .store(in: &cancellables)

    shortcutManager.eventPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.resetMenu()
      }
      .store(in: &cancellables)

    NotificationCenter.default.addObserver(self, selector: #selector(resetMenu), name: .onUpdateFavoriteDevices, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc
  private func resetMenu() {
    deviceMenu = nil
  }

  @objc
  private func updateMenuBarIcon(_ audioDeviceID: AudioDeviceID) {
    guard
      let device = deviceStore.getDeviceByID(audioDeviceID),
      let icon = makeBarIcon(for: device.outputType),
      let button = statusItem.button,
      button.image != icon
    else {
      logger.warning("Cannot update menu bar icon")
      return
    }

    resetMenu()
    button.image = icon
    NotificationHelper.showNotification(with: "Switched to \(device.name)")
  }

  private var iconCache = [String: NSImage]()

  private func makeBarIcon(for audioOutputType: AudioOutputType) -> NSImage? {
    if let cachedIcon = iconCache[audioOutputType.imageName] {
      return cachedIcon
    }

    guard let icon = NSImage(named: audioOutputType.imageName) else {
      return nil
    }

    icon.size = NSSize(width: 20, height: 18)
    icon.isTemplate = true
    icon.resizingMode = .tile

    iconCache[audioOutputType.imageName] = icon
    return icon
  }

  @objc
  private func toggleAudioOutput() {
    guard let event = NSApp.currentEvent else {
      return
    }

    if event.type == .rightMouseUp {
      showDeviceMenu()
    } else {
      if let device = deviceStore.switchToNextOutput() {
        NotificationHelper.showNotification(with: "Switched to \(device.name)")
      }
    }
  }

  private func showDeviceMenu() {
    if deviceMenu == nil {
      deviceMenu = createDeviceMenu()
    }

    if let button = statusItem.button {
      let point = NSPoint(x: 0, y: button.bounds.height + 2)
      deviceMenu?.popUp(positioning: deviceMenu?.item(at: 0), at: point, in: button)
    }
  }

  private func createDeviceMenu() -> NSMenu {
    let menu = NSMenu()
    let devices = deviceStore.getShowableDevices()

    for device in devices {
      let menuItem = NSMenuItem(
        title: device.name,
        action: #selector(selectDevice(_:)),
        keyEquivalent: deviceStore.getShortcutKeyCodeStringForDevice(device))
      menuItem.target = self
      menuItem.representedObject = device

      if device.isDefault {
        menuItem.state = .on
      }

      menu.addItem(menuItem)
    }

    menu.addItem(NSMenuItem.separator())

    let preferencesItem = NSMenuItem(
      title: "Preferences...",
      action: #selector(showPreferences),
      keyEquivalent: ",")
    preferencesItem.target = self
    menu.addItem(preferencesItem)

    let helpItem = NSMenuItem(title: "Help", action: #selector(showHelp), keyEquivalent: "")
    helpItem.target = self
    menu.addItem(helpItem)

    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    return menu
  }

  @objc
  private func showPreferences() {
    delegate?.didPressPreferences()
  }

  @objc
  private func showHelp() {
    delegate?.didPressHelp()
  }

  @objc
  private func selectDevice(_ sender: NSMenuItem) {
    guard let device = sender.representedObject as? AudioDevice else {
      return
    }

    _ = deviceStore.setDefaultOutput(device)
  }
}
