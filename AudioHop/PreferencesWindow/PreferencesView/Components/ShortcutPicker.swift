//
//  ShortcutPicker.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import SwiftUI
import MASShortcut

struct ShortcutPickerView: NSViewRepresentable {
  var shortcutValue: MASShortcut?
  var onShortcutChange: (MASShortcut?) -> Void

  private let fixedWidth: CGFloat = 100

  func makeNSView(context: Context) -> MASShortcutView {
    let view = MASShortcutView(frame: .zero)
    if let shortcutValue {
      view.shortcutValue = shortcutValue
    }
    view.shortcutValueChange = { shortcutView in
      onShortcutChange(shortcutView?.shortcutValue)
    }

    view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(equalToConstant: fixedWidth)
    ])

    return view
  }

  func updateNSView(_ nsView: MASShortcutView, context: Context) {}
}
