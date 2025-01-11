//
//  NSImageRepresentable.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 14.11.2024.
//

import AppKit
import SwiftUI

struct GIFImageView: NSViewRepresentable {
  let imageName: String

  private func getGifUrl(named name: String) -> URL? {
    Bundle.main.url(forResource: name, withExtension: "gif")
  }

  func makeNSView(context _: Context) -> NSImageView {
    let imageView = NSImageView()
    imageView.canDrawSubviewsIntoLayer = true
    imageView.imageScaling = .scaleProportionallyUpOrDown
    imageView.animates = true
    if let gifUrl = getGifUrl(named: imageName), let gifImage = NSImage(contentsOf: gifUrl) {
      imageView.image = gifImage
    }
    return imageView
  }

  func updateNSView(_ nsView: NSImageView, context _: Context) {
    if let gifUrl = getGifUrl(named: imageName), let gifImage = NSImage(contentsOf: gifUrl) {
      nsView.image = gifImage
    }
  }
}
