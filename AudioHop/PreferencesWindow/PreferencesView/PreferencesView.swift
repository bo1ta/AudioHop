//
//  PreferencesView.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import SwiftUI
import AppKit
import Foundation
import Factory

struct PreferencesView: View {
  @Injected(\.deviceStore) private var deviceStore

  @State private var viewModel = PreferencesViewModel()

  var body: some View {
    VStack(spacing: 16) {
      Text("Audio Device Preferences")
        .font(.headline)

      Text("Select your favorite devices to include in quick switching")
        .font(.subheadline)
        .foregroundColor(.secondary)

      List {
        ForEach(viewModel.devices, id: \.id) { device in
          let shortcut = viewModel.getShortcut(for: device.id)
          DeviceRow(
            device: device,
            shortcut: shortcut,
            isFavorite: viewModel.isFavorite(device.id),
            onToggle: { viewModel.toggleFavorite(for: device.id) },
            onAddedShortcut: { newShortcut in
              viewModel.setShortcut(newShortcut, for: device.id)
            }
          )
        }
      }

      Toggle("Open app on launch", isOn: Binding(
        get: { viewModel.launchAtLogin },
        set: { _ in viewModel.toggleLaunchAtLogin() }
      ))
      .padding(.horizontal)
    }
    .padding()
    .frame(width: 400, height: 300)
  }
}
