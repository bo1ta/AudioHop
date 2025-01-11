//
//  AudioManager.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 01.11.2024.
//

import AudioToolbox
import Foundation
import Factory

public final class AudioManager {
  @Injected(\.logger) private var logger: Logger

  func getOutputDevices() -> [AudioDevice] {
    var devices: [AudioDevice] = []

    var addressStreamConfiguration = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreamConfiguration,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain)
    var addressTransportType = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyTransportType,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain)
    var addressDeviceName = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceNameCFString,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain)

    var propertySize = UInt32(0)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain)

    var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize)
    guard status == noErr else {
      logger.error(CustomError.invalidDeviceList, message: "Error getting device list size: \(status)")
      return []
    }

    let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
    var deviceIDBuffer = [AudioDeviceID](repeating: 0, count: deviceCount)

    status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &deviceIDBuffer)
    guard status == noErr else {
      logger.error(CustomError.invalidDeviceList, message: "Error getting device data: \(status)")
      return []
    }

    // Retrieve the default output device ID
    var defaultOutputID: AudioDeviceID = 0
    address.mSelector = kAudioHardwarePropertyDefaultOutputDevice
    propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
    status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &defaultOutputID)

    guard status == noErr else {
      logger.error(CustomError.invalidDeviceList, message: "Error getting default output device: \(status)")
      return []
    }

    devices = deviceIDBuffer.compactMap { deviceID in
      guard
        hasOutputCapability(deviceID: deviceID, address: &addressStreamConfiguration),
        let name = getDeviceName(deviceID: deviceID, address: &addressDeviceName),
        let outputType = getDeviceType(deviceID: deviceID, address: &addressTransportType)
      else {
        return nil
      }

      return AudioDevice(id: deviceID, name: name, isDefault: deviceID == defaultOutputID, outputType: outputType)
    }

    return devices
  }

  func getDeviceID(_ address: inout AudioObjectPropertyAddress) -> AudioDeviceID {
    var deviceID: AudioDeviceID = 0
    var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)

    let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &deviceID)
    guard status == noErr else {
      logger.error(CustomError.invalidDevice, message: "Error getting default device ID: \(status)")
      return 0
    }

    return deviceID
  }

  func getDefaultOutputDeviceID() -> AudioDeviceID {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultOutputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    return getDeviceID(&address)
  }

  func setDefaultOutputDevice(deviceID: AudioDeviceID) -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultOutputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    var mutableDeviceID = deviceID
    let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &mutableDeviceID)
    return status == noErr
  }

  private func getDeviceName(deviceID: AudioDeviceID, address: inout AudioObjectPropertyAddress) -> String? {
    var name: Unmanaged<CFString>?
    var propertySize = UInt32(MemoryLayout.size(ofValue: name))

    let status = withUnsafeMutablePointer(to: &name) { namePointer in
      AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propertySize, namePointer)
    }

    guard status == noErr else {
      logger.error(CustomError.invalidDevice, message: "Error getting device name: \(status)")
      return nil
    }

    return name?.takeRetainedValue() as? String
  }

  private func hasOutputCapability(deviceID: AudioDeviceID, address: inout AudioObjectPropertyAddress) -> Bool {
    var propertySize: UInt32 = 0

    var status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &propertySize)
    guard status == noErr else {
      logger.error(CustomError.invalidDevice, message: "Error getting data size: \(status)")
      return false
    }

    let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propertySize))
    defer { bufferList.deallocate() }

    status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propertySize, bufferList)
    guard status == noErr else {
      logger.error(CustomError.invalidDevice, message: "Error getting property data: \(status)")
      return false
    }

    return true
  }


  func getDeviceCount() -> UInt32 {
    var propertySize = UInt32(MemoryLayout<UInt32>.size)

    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize)
    guard status == noErr else {
      logger.error(CustomError.invalidDeviceList, message: "Error getting device count: \(status)")
      return 0
    }

    return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
  }

  func listOutputDeviceNames() {
    var propertySize = UInt32(0)
    var devicesAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain
    )

    var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &devicesAddress, 0, nil, &propertySize)
    guard status == noErr else {
      logger.error(CustomError.invalidDeviceList, message: "Error getting device list size: \(status)")
      return
    }

    let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
    var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

    status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &devicesAddress, 0, nil, &propertySize, &deviceIDs)
    guard status == noErr else {
      logger.error(CustomError.invalidDeviceList, message: "Error getting device IDs: \(status)")
      return
    }

    var deviceNameAddress = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyDeviceNameCFString,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain)

    for deviceID in deviceIDs {
      if let name = getDeviceName(deviceID: deviceID, address: &deviceNameAddress) {
        logger.info("Output Device: \(name)")
      } else {
        logger.info("Error retrieving name for device ID \(deviceID):")
      }
    }
  }

  private func getDeviceType(deviceID: AudioDeviceID, address: inout AudioObjectPropertyAddress) -> AudioOutputType? {
    var transportType = UInt32(0)
    var propertySize = UInt32(MemoryLayout<UInt32>.size)

    let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propertySize, &transportType)
    guard status == noErr else {
      logger.error(CustomError.invalidDevice, message: "Error getting transport type: \(status)")
      return nil
    }

    let outputType: AudioOutputType
    switch transportType {
    case kAudioDeviceTransportTypeBuiltIn:
      if isHeadphones(deviceID: deviceID) {
        outputType = .headphones
      } else {
        outputType = .builtIn
      }
    case kAudioDeviceTransportTypeHDMI:
      outputType = .hdmi
    case kAudioDeviceTransportTypeUSB:
      outputType = .usb
    case kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE:
      outputType = .bluetoothDevice
    case kAudioDeviceTransportTypeDisplayPort:
      outputType = .displayPort
    case kAudioDeviceTransportTypeAirPlay:
      outputType = .airplay
    default:
      outputType = .unknown
    }

    return outputType
  }

  private func isHeadphones(deviceID: AudioDeviceID) -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyDataSource,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain
    )

    var dataSource = UInt32(0)
    var propertySize = UInt32(MemoryLayout<UInt32>.size)

    let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propertySize, &dataSource)

    guard status == noErr else {
      logger.error(CustomError.invalidDevice, message: "Failed to get property data source \(status)")
      return false
    }
    return dataSource == FourCharCode("hdpn")
  }
}

extension AudioManager {
  enum CustomError: Error {
    case invalidDeviceList
    case invalidRunLoopListener
    case invalidDefaultDevice
    case invalidDevice
  }
}
