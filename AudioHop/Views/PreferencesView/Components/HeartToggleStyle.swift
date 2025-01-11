//
//  HeartToggleStyle.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 02.11.2024.
//

import SwiftUI

struct HeartToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button(action: {
      configuration.isOn.toggle()
    }, label: {
      Image(systemName: configuration.isOn ? "heart.fill" : "heart")
        .foregroundColor(configuration.isOn ? .red : .white)
        .shadow(radius: 1.2)
    })
    .buttonStyle(PlainButtonStyle())
  }
}
