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
open class AKDevice: NSObject {
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
    public init(name: String, deviceID: DeviceID, dataSource: String = "") {
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

    #if !os(macOS)
    /// Initialize the device
    ///
    /// - Parameters:
    ///   - portDescription: A port description object that describes a single
    /// input or output port associated with an audio route.
    ///
    public convenience init(portDescription: AVAudioSessionPortDescription) {
        let portData = [portDescription.uid, portDescription.selectedDataSource?.dataSourceName]
        let deviceID = portData.compactMap { $0 }.joined(separator: " ")
        self.init(name: portDescription.portName, deviceID: deviceID)
    }

    /// Return a port description matching the devices name.
    var portDescription: AVAudioSessionPortDescription? {
        return AVAudioSession.sharedInstance().availableInputs?.filter { $0.portName == name }.first
    }

    /// Return a data source matching the devices deviceID.
    var dataSource: AVAudioSessionDataSourceDescription? {
        let dataSources = portDescription?.dataSources ?? []
        return dataSources.filter { deviceID.contains($0.dataSourceName) }.first
    }
    #endif

    /// Printable device description
    open override var description: String {
        return "<Device: \(name) (\(deviceID))>"
    }

    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AKDevice {
            return self.name == object.name && self.deviceID == object.deviceID
        }
        return false
    }

}
