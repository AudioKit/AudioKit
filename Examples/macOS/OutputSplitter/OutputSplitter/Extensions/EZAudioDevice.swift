//
//  EZAudioDevice.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 30/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioKit

extension EZAudioDevice {
    var isAlive: Bool {
        get {
            return boolPropertyForSelector(kAudioDevicePropertyDeviceIsAlive)
        }
    }

    var isRunningSomewhere: Bool {
        get {
            return boolPropertyForSelector(kAudioDevicePropertyDeviceIsRunningSomewhere)
        }
    }

    var transportType: UInt32 {
        get {
            var address = EZAudioDevice.addressForPropertySelector(kAudioDevicePropertyTransportType)
            var result: UInt32 = 0
            var size = UInt32(MemoryLayout<UInt32>.size)
            checkErr(AudioObjectGetPropertyData(self.deviceID, &address, 0, nil, &size, &result))
            return result
        }
    }

    func boolPropertyForSelector (_ selector: AudioObjectPropertySelector) -> Bool {
        var address = EZAudioDevice.addressForPropertySelector(selector)
        var result: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        checkErr(AudioObjectGetPropertyData(self.deviceID, &address, 0, nil, &size, &result))
        return result == 1
    }

    static var buildInOutput: EZAudioDevice? {
        get {
            let device = (EZAudioDevice.outputDevices() as! [EZAudioDevice]).first { $0.transportType == kAudioDeviceTransportTypeBuiltIn }
            return device
        }
    }
    static func addressForPropertySelector (_ selector: AudioObjectPropertySelector) -> AudioObjectPropertyAddress {
        var address = AudioObjectPropertyAddress()
        address.mScope = kAudioObjectPropertyScopeGlobal
        address.mElement = kAudioObjectPropertyElementMaster
        address.mSelector = selector
        return address
    }
}
