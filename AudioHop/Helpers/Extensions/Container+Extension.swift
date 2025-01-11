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
      .shared
  }

  var audioManager: Factory<AudioManager> {
    self { AudioManager() }
      .singleton
  }

  var logger: Factory<Logger> {
    self { SentryLogger() }
      .onDebug { DebugLogger() }
      .singleton
  }

  var deviceStore: Factory<AudioDeviceStore> {
    self { AudioDeviceStore() }
      .shared
  }

  var defaultDeviceListener: Factory<DefaultOutputDeviceListener> {
    self { DefaultOutputDeviceListener() }
      .cached
  }
}
