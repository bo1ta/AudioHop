//
//  DeviceRow.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import MASShortcut
import SwiftUI

struct DeviceRow: View {
  let device: AudioDevice
  var shortcut: MASShortcut?
  let isFavorite: Bool
  let onToggle: () -> Void
  let onAddedShortcut: (MASShortcut?) -> Void

  var body: some View {
    HStack {
      Toggle("", isOn: .init(
        get: { isFavorite },
        set: { _ in onToggle() }
      ))
      .toggleStyle(HeartToggleStyle())

      VStack(alignment: .leading) {
        Text(device.name)
          .font(.body)
        if device.isDefault {
          Text("Current Default")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }

      Spacer()

      ShortcutPickerView(shortcutValue: shortcut) { newShortcut in
        onAddedShortcut(newShortcut)
      }
    }
    .padding(.vertical, 2)
  }
}

#Preview {
  DeviceRow(
    device: .init(
      id: 0,
      name: "Device 0",
      isDefault: false,
      outputType: .airplay),
    shortcut: nil,
    isFavorite: false,
    onToggle: { },
    onAddedShortcut: { _ in })
}
