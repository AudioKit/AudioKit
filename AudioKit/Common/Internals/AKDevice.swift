//
//  AKDevice.swift
//  AudioKit
//
//  Created by Stéphane Peter on 2/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

#if os(OSX)
public typealias DeviceID = AudioDeviceID
#else
public typealias DeviceID = String
#endif
    
/// Wrapper for audio device selection
@objc public class AKDevice : NSObject {
    /// The human-readable name for the device.
    public var name: String
    
    /// The device identifier.
    public private(set) var deviceID: DeviceID

    /// Initialize the device
    ///
    /// - parameter name: The human-readable name for the device.
    /// - parameter deviceID: The device identifier.
    ///
    public init(name: String, deviceID: DeviceID) {
        self.name = name
        self.deviceID = deviceID
        super.init()
    }
    
    /// Printable device description
    public override var description: String {
        return "<Device: \(name) (\(deviceID))>"
    }
}