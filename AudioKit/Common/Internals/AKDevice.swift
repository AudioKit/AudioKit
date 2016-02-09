//
//  AKDevice.swift
//  AudioKit
//
//  Created by Stéphane Peter on 2/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

@objc
public class AKDevice : NSObject
{
    /// The human-readable name for the device.
    public var name: String
    
    /// The device identifier.
    #if os(OSX)
    public private(set) var deviceID: AudioDeviceID
    #else
    public private(set) var deviceID: String
    #endif

    #if os(OSX)
    public init(name: String, deviceID: AudioDeviceID)
    {
        self.name = name
        self.deviceID = deviceID
        super.init()
    }
    #else
    public init(name: String, deviceID: String)
    {
        self.name = name
        self.deviceID = deviceID
        super.init()
    }
    #endif
    
    public override var description: String
    {
        return "<Device: \(name) (\(deviceID))>"
    }
}