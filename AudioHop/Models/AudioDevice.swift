//
//  AudioDevice.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import AudioToolbox
import Foundation

struct AudioDevice: Codable, Identifiable {
  var id: AudioDeviceID
  var name: String
  var isDefault: Bool
  var outputType: AudioOutputType
  var isFavorite = false
  var shortcut: [String: Any]?

  enum CodingKeys: String, CodingKey {
    case id, name, isDefault, outputType, isFavorite, shortcut
  }

  init(
    id: AudioDeviceID,
    name: String,
    isDefault: Bool,
    outputType: AudioOutputType,
    isFavorite: Bool = false,
    shortcut: [String: Any]? = nil)
  {
    self.id = id
    self.name = name
    self.isDefault = isDefault
    self.outputType = outputType
    self.isFavorite = isFavorite
    self.shortcut = shortcut
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(AudioDeviceID.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    isDefault = try container.decode(Bool.self, forKey: .isDefault)
    outputType = try container.decode(AudioOutputType.self, forKey: .outputType)
    isFavorite = try container.decode(Bool.self, forKey: .isFavorite)

    if let shortcutData = try container.decodeIfPresent(Data.self, forKey: .shortcut) {
      shortcut = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shortcutData) as? [String: Any]
    } else {
      shortcut = nil
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(isDefault, forKey: .isDefault)
    try container.encode(outputType.rawValue, forKey: .outputType)
    try container.encode(isFavorite, forKey: .isFavorite)

    if let shortcut {
      let shortcutData = try NSKeyedArchiver.archivedData(
        withRootObject: shortcut,
        requiringSecureCoding: false)
      try container.encode(shortcutData, forKey: .shortcut)
    }
  }
}

extension AudioDevice: Equatable {
    static func ==(lhs: AudioDevice, rhs: AudioDevice) -> Bool {
    lhs.id == rhs.id
  }
}
