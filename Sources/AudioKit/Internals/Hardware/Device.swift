// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)
/// DeviceID isan AudioDeviceID on macOS
public typealias DeviceID = AudioDeviceID
#else
/// DeviceID is a string on iOS
public typealias DeviceID = String
#endif

import AVFoundation

/// Wrapper for audio device selection
public struct Device: Equatable, Hashable {
    /// The human-readable name for the device.
    public private(set) var name: String
    /// Number of input channels
    public private(set) var nInputChannels: Int?
    /// Number of output channels
    public private(set) var nOutputChannels: Int?

    /// The device identifier.
    public private(set) var deviceID: DeviceID

    /// Initialize the device
    ///
    /// - Parameters:
    ///   - name: The human-readable name for the device.
    ///   - deviceID: The device identifier.
    ///   - dataSource: String describing data source
    ///
    public init(name: String, deviceID: DeviceID, dataSource: String = "") {
        self.name = name
        self.deviceID = deviceID
        #if !os(macOS)
        if dataSource != "" {
            self.deviceID = "\(deviceID) \(dataSource)"
        }
        #endif
    }

    #if os(macOS)
    /// Initialize the device
    /// - Parameter deviceID: DeviceID
    public init(deviceID: DeviceID) {
        self.init(name: AudioDeviceUtils.name(deviceID), deviceID: deviceID)
        nInputChannels = AudioDeviceUtils.inputChannels(deviceID)
        nOutputChannels = AudioDeviceUtils.outputChannels(deviceID)
    }
    #endif

    #if !os(macOS)
    /// Initialize the device
    ///
    /// - Parameters:
    ///   - portDescription: A port description object that describes a single
    /// input or output port associated with an audio route.
    ///
    public init(portDescription: AVAudioSessionPortDescription) {
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
}

extension Device: CustomDebugStringConvertible {
    /// Printout for debug
    public var debugDescription: String {
        return "<Device: \(name) (\(deviceID))>"
    }
}
