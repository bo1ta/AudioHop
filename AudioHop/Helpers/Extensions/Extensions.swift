//
//  Extensions.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 14.01.2025.
//

import Foundation

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

extension NSNotification.Name {
  static let onUpdateFavoriteDevices = NSNotification.Name("onUpdateFavoriteDevices")
}
