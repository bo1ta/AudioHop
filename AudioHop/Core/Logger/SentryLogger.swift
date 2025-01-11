//
//  SentryLogger.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 03.11.2024.
//

import Foundation
import Sentry

// MARK: - SentryLogger

final class SentryLogger: Logger {
  func configure() {
    SentrySDK.start { options in
      options.dsn = "https://f982c0694a18bffd662b0908914957a5@o4508234235445248.ingest.de.sentry.io/4508234237476944"
      options.environment = "debug"
      options.debug = true
    }
  }

  func log(message: String, level: LogLevel, error: Error?) {
    let sentryEvent = Sentry.Event(level: level.toSentryLevel())
    sentryEvent.message = .init(formatted: message)

    if let error {
      SentrySDK.capture(error: error) { scope in
        scope.setExtras(["message": message])
      }
    } else {
      SentrySDK.capture(event: sentryEvent)
    }
  }
}

extension LogLevel {
  fileprivate func toSentryLevel() -> SentryLevel {
    switch self {
    case .debug: .debug
    case .info: .info
    case .warning: .warning
    case .error: .error
    }
  }
}
