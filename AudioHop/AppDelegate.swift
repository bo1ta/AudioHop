//
//  AppDelegate.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import Cocoa
import AppKit
import Factory

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  @Injected(\.shortcutManager) private var shortcutManager: ShortcutManager
  @Injected(\.logger) private var logger: Logger
  @Injected(\.deviceStore) private var deviceStore: AudioDeviceStore
  @Injected(\.defaultDeviceListener) private var defaultDeviceListener

  private var statusBarManager: StatusBarManager!
  private var userNotificationManager: NotificationManager!

  var preferencesWindowController: PreferencesWindowController?
  var onboardingWindowController: OnboardingWindowController?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    logger.configure()

    deviceStore.initialLoad()

    userNotificationManager = NotificationManager()

    statusBarManager = StatusBarManager()
    statusBarManager.delegate = self

    defaultDeviceListener.start()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    NotificationCenter.default.removeObserver(self)
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

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
