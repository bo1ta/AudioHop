//
//  DefaultOutputDeviceListener.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 11.01.2025.
//

import Combine
import CoreAudio
import Factory

final class DefaultOutputDeviceListener {
  @Injected(\.logger) private var logger
  @Injected(\.audioManager) private var audioManager

  private let queue = DispatchQueue(label: "DefaultOutputDeviceListener")
  private let didChangeDefaultDeviceSubject = PassthroughSubject<AudioObjectID, Never>()
  private let objectID: AudioObjectID

  private var objectPropertyAddress: AudioObjectPropertyAddress

  var didChangeDefaultDevice: AnyPublisher<AudioObjectID, Never> {
    didChangeDefaultDeviceSubject.eraseToAnyPublisher()
  }

  init() {
    objectID = AudioObjectID(kAudioObjectSystemObject)
    objectPropertyAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultOutputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
  }

  func start() {
    let status = AudioObjectAddPropertyListenerBlock(objectID, &objectPropertyAddress, queue, handleDeviceChange(_:addresses:))

    if status != noErr {
      logger.log(message: "Could not add property listener: \(status)", level: .error, error: nil)
    }
  }

  func stop() {
    let status = AudioObjectRemovePropertyListenerBlock(objectID, &objectPropertyAddress, queue, handleDeviceChange(_:addresses:))
    if status != noErr {
      logger.log(message: "Could not remove property listener: \(status)", level: .error, error: nil)
    }
  }

  private func handleDeviceChange(_ numberOfAddresses: UInt32, addresses: UnsafePointer<AudioObjectPropertyAddress>) {
    var index: UInt32 = 0

    while index < numberOfAddresses {
      var address: AudioObjectPropertyAddress = addresses[Int(index)]

      switch address.mSelector {
      case kAudioHardwarePropertyDefaultOutputDevice:
        let deviceID = audioManager.getDeviceID(&address)
        didChangeDefaultDeviceSubject.send(deviceID)

      default:
        logger.warning("Unexpected case for listener block. Selector: \(address.mSelector) ")
      }

      index += 1
    }
  }
}
