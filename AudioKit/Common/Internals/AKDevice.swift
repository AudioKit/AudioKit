//
//  AKDevice.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#if os(macOS)
public typealias DeviceID = AudioDeviceID
#else
public typealias DeviceID = String
#endif

/// Wrapper for audio device selection
@objc open class AKDevice: NSObject {
    /// The human-readable name for the device.
    open var name: String
    open var nInputChannels: Int?
    open var nOutputChannels: Int?

    /// The device identifier.
    open fileprivate(set) var deviceID: DeviceID

    /// Initialize the device
    ///
    /// - Parameters:
    ///   - name: The human-readable name for the device.
    ///   - deviceID: The device identifier.
    ///
    @objc public init(name: String, deviceID: DeviceID, dataSource: String = "") {
        self.name = name
        self.deviceID = deviceID
        #if !os(macOS)
        if dataSource != "" {
            self.deviceID = "\(deviceID) \(dataSource)"
        }
        #endif
        super.init()
    }

    #if os(macOS)
    public convenience init(ezAudioDevice: EZAudioDevice) {
        self.init(name: ezAudioDevice.name, deviceID: ezAudioDevice.deviceID)
        self.nInputChannels = ezAudioDevice.inputChannelCount
        self.nOutputChannels = ezAudioDevice.outputChannelCount
    }
    #endif

    /// Printable device description
    override open var description: String {
        return "<Device: \(name) (\(deviceID))>"
    }
}
