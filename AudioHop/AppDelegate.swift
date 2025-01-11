//
//  AppDelegate.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import AppKit
import Cocoa
import Factory

// MARK: - AppDelegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  @Injected(\.shortcutManager) private var shortcutManager: ShortcutManager
  @Injected(\.logger) private var logger: Logger
  @Injected(\.deviceStore) private var deviceStore: AudioDeviceStore
  @Injected(\.defaultDeviceListener) private var defaultDeviceListener

  var preferencesWindowController: PreferencesWindowController?
  var onboardingWindowController: OnboardingWindowController?

  private let statusBarManager: StatusBarManager
  private let notificationWrapper: UNNotificationWrapper

  override init() {
    notificationWrapper = UNNotificationWrapper()
    statusBarManager = StatusBarManager()

    super.init()
  }

  func applicationDidFinishLaunching(_: Notification) {
    // Configure app to be menu-bar only
    NSApp.setActivationPolicy(.accessory)

    // Activate delegate callbacks for Status Bar
    statusBarManager.delegate = self

    // Prepare for logging
    logger.configure()

    // Activate shortcuts
    shortcutManager.setupShortcuts()

    // Populate device store with current output devices
    deviceStore.initialLoad()

    // Status bar is now ready for setup
    statusBarManager.setupStatusButton()

    // Start listening to changes on the default output audio device
    defaultDeviceListener.start()
  }

  func applicationWillTerminate(_: Notification) {
    defaultDeviceListener.stop()
  }

  func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
    true
  }
}

// MARK: StatusBarManagerDelegate

extension AppDelegate: StatusBarManagerDelegate {
  func didPressPreferences() {
    if preferencesWindowController == nil {
      preferencesWindowController = PreferencesWindowController()
    }

    preferencesWindowController?.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func didPressHelp() {
    if onboardingWindowController == nil {
      onboardingWindowController = OnboardingWindowController()
    }

    onboardingWindowController?.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
