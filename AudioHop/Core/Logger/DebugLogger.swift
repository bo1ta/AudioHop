//
//  DebugLogger.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 03.11.2024.
//

import Foundation

// MARK: - DebugLogger

class DebugLogger: Logger {
  func configure() { }

  func log(message: String, level: LogLevel, error: Error?) {
    let levelEmoji = level.emoji
    let errorDescription = error?.localizedDescription ?? ""
    let message = "[\(levelEmoji)] \(errorDescription) - \(message) "
    print(message)
  }
}

extension LogLevel {
  fileprivate var emoji: String {
    switch self {
    case .info:
      "ℹ️"
    case .warning:
      "⚠️"
    case .error:
      "❌"
    case .debug:
      "👀"
    }
  }
}
