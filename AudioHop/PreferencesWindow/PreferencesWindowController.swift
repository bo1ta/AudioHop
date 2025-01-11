//
//  PreferencesWindowController.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import SwiftUI

class PreferencesWindowController: NSWindowController {
  convenience init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )

    window.center()
    window.setFrameAutosaveName("Preferences")
    window.contentView = NSHostingView(rootView: PreferencesView())
    window.title = "Preferences"
    window.isReleasedWhenClosed = true

    self.init(window: window)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowWillClose),
      name: NSWindow.willCloseNotification,
      object: window
    )
  }

  @objc private func windowWillClose() {
    if let delegate = NSApplication.shared.delegate as? AppDelegate {
      delegate.preferencesWindowController = nil
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}


class OnboardingWindowController: NSWindowController {
  convenience init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )

    window.center()
    window.setFrameAutosaveName("Preferences")
    window.contentView = NSHostingView(rootView: OnboardingView())
    window.title = "Onboarding"
    window.isReleasedWhenClosed = true

    self.init(window: window)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowWillClose),
      name: NSWindow.willCloseNotification,
      object: window
    )
  }

  @objc private func windowWillClose() {
    if let delegate = NSApplication.shared.delegate as? AppDelegate {
      delegate.onboardingWindowController = nil
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
