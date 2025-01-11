//
//  AudioOutputType.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import Foundation

enum AudioOutputType: String, Decodable {
  case builtIn
  case headphones
  case bluetoothDevice
  case airplay
  case usb
  case hdmi
  case displayPort
  case unknown

  var imageName: String {
    switch self {
    case .builtIn:
      "laptop-volume-icon"
    case .headphones:
      "headphones-icon"
    case .bluetoothDevice:
      "bluetooth-icon"
    case .airplay:
      "airplay-icon"
    case .hdmi:
      "monitor-icon"
    case .displayPort:
      "monitor-icon"
    case .usb:
      "monitor-icon"
    case .unknown:
      "equalizer-icon"
    }
  }
}
