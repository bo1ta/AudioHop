//
//  Container+Extension.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 03.11.2024.
//

import Factory
import Foundation

extension Container {
  var shortcutManager: Factory<ShortcutManager> {
    self { ShortcutManager() }
      .cached
  }

  var deviceStore: Factory<AudioDeviceStore> {
    self { AudioDeviceStore() }
      .cached
  }

  var defaultDeviceListener: Factory<DefaultOutputDeviceListener> {
    self { DefaultOutputDeviceListener() }
      .cached
  }

  var audioManager: Factory<AudioManager> {
    self { AudioManager() }
      .shared
  }

  var logger: Factory<Logger> {
    self { SentryLogger() }
      .onDebug { DebugLogger() }
      .singleton
  }
}
