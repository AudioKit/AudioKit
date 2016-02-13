//
//  AKDevice.swift
//  AudioKit
//
//  Created by Stéphane Peter on 2/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Wrapper for audio device selection
@objc public class AKDevice : NSObject {
    /// The human-readable name for the device.
    public var name: String
    
    #if os(OSX)
    
    /// The device identifier.
    public private(set) var deviceID: AudioDeviceID
    
    #else
    
    /// The device identifier.
    public private(set) var deviceID: String
    
    #endif

    #if os(OSX)
    
    /// Initialize the device
    ///
    /// - parameter name: The human-readable name for the device.
    /// - paramter deviceID: The device identifier.
    ///
    public init(name: String, deviceID: AudioDeviceID) {
        self.name = name
        self.deviceID = deviceID
        super.init()
    }
    
    #else
    
    /// Initialize the device
    ///
    /// - parameter name: The human-readable name for the device.
    /// - paramter deviceID: The device identifier.
    ///
    public init(name: String, deviceID: String) {
        self.name = name
        self.deviceID = deviceID
        super.init()
    }
    
    #endif
    
    /// Printable device description
    public override var description: String {
        return "<Device: \(name) (\(deviceID))>"
    }
}