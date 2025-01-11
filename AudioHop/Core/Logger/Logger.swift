//
//  Logger.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 03.11.2024.
//

enum LogLevel: String {
  case info
  case warning
  case error
  case debug
}

protocol Logger {
  func configure()
  func log(message: String, level: LogLevel, error: Error?)
}

extension Logger {
  func error(_ error: Error, message: String? = nil) {
    log(message: message ?? "", level: .error, error: error)
  }

  func warning(_ message: String) {
    log(message: message, level: .warning, error: nil)
  }

  func info(_ message: String) {
    log(message: message, level: .info, error: nil)
  }
}
