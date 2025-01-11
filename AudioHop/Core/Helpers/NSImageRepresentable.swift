//
//  NSImageRepresentable.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 14.11.2024.
//

import SwiftUI
import AppKit

struct GIFImageView: NSViewRepresentable {
  let imageName: String

  private func getGifUrl(named name: String) -> URL? {
      return Bundle.main.url(forResource: name, withExtension: "gif")
  }

  func makeNSView(context: Context) -> NSImageView {
    let imageView = NSImageView()
    imageView.canDrawSubviewsIntoLayer = true
    imageView.imageScaling = .scaleProportionallyUpOrDown
    imageView.animates = true
    if let gifUrl = getGifUrl(named: imageName), let gifImage = NSImage(contentsOf: gifUrl) {
      imageView.image = gifImage
    }
    return imageView
  }

  func updateNSView(_ nsView: NSImageView, context: Context) {
    if let gifUrl = getGifUrl(named: imageName), let gifImage = NSImage(contentsOf: gifUrl) {
      nsView.image = gifImage
    }
  }
}
