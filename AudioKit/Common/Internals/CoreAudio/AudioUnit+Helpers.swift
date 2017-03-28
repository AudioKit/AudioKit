//
//  AudioUnit+Helpers.swift
//  AudioKit
//
//  Created by Daniel Clelland on 25/06/16.
//  Updated for AudioKit 3 by Aurelius Prochazka.
//
//  Copyright © 2017 Daniel Clelland. All rights reserved.
//

import CoreAudio

// MARK: - AudioUnit helpers

public extension AudioUnit {

    func getValue<T>(forProperty property: AudioUnitPropertyID) -> T {
        let (dataSize, _) = try! getPropertyInfo(propertyID: property)
        return try! getProperty(propertyID: property, dataSize: dataSize)
    }

    func setValue<T>(value: T, forProperty property: AudioUnitPropertyID) {
        let (dataSize, _) = try! getPropertyInfo(propertyID: property)
        return try! setProperty(propertyID: property, dataSize: dataSize, data: value)
    }

    func add(listener: AudioUnitPropertyListener, toProperty property: AudioUnitPropertyID) {
        do {
            try addPropertyListener(listener: listener, toProperty: property)
        } catch {
            AKLog("Error Adding Property Listener")
        }
    }

    func remove(listener: AudioUnitPropertyListener, fromProperty property: AudioUnitPropertyID) {
        do {
            try removePropertyListener(listener: listener, fromProperty: property)
        } catch {
            AKLog("Error Removing Property Listener")
        }
    }

}

// MARK: - AudioUnit callbacks

public struct AudioUnitPropertyListener {

    public typealias AudioUnitPropertyListenerCallback = (
        _ audioUnit: AudioUnit,
        _ property: AudioUnitPropertyID) -> Void

    let proc: AudioUnitPropertyListenerProc
    let procInput: UnsafeMutablePointer<AudioUnitPropertyListenerCallback>

    public init(callback: @escaping AudioUnitPropertyListenerCallback) {
        self.proc = { (inRefCon, inUnit, inID, inScope, inElement) in

//            UnsafeMutablePointer<Callback>(inRefCon).memory(audioUnit: inUnit, property: inID)
            inRefCon.assumingMemoryBound(to: AudioUnitPropertyListenerCallback.self).pointee(inUnit, inID)
        }

        self.procInput = UnsafeMutablePointer<AudioUnitPropertyListenerCallback>.allocate(
            capacity: MemoryLayout<AudioUnitPropertyListenerCallback>.stride
        )
        self.procInput.initialize(to: callback)
    }

}

// MARK: - AudioUnit function wrappers

public extension AudioUnit {

    func getPropertyInfo(propertyID: AudioUnitPropertyID) throws -> (dataSize: UInt32, writable: Bool) {
        var dataSize: UInt32 = 0
        var writable: DarwinBoolean = false

        try AudioUnitGetPropertyInfo(self, propertyID, kAudioUnitScope_Global, 0, &dataSize, &writable).check()

        return (dataSize: dataSize, writable: writable.boolValue)
    }

    func getProperty<T>(propertyID: AudioUnitPropertyID, dataSize: UInt32) throws -> T {
        var dataSize = dataSize
        var data = UnsafeMutablePointer<T>.allocate(capacity: Int(dataSize))
        defer {
            data.deallocate(capacity: Int(dataSize))
        }

        try AudioUnitGetProperty(self, propertyID, kAudioUnitScope_Global, 0, data, &dataSize).check()

        return data.pointee
    }

    func setProperty<T>(propertyID: AudioUnitPropertyID, dataSize: UInt32, data: T) throws {
        var data = data

        try AudioFileSetProperty(self, propertyID, dataSize, &data).check()
    }

    internal func addPropertyListener(listener: AudioUnitPropertyListener,
                                      toProperty propertyID: AudioUnitPropertyID) throws {
        try AudioUnitAddPropertyListener(self, propertyID, listener.proc, listener.procInput).check()
    }

    internal func removePropertyListener(listener: AudioUnitPropertyListener,
                                         fromProperty propertyID: AudioUnitPropertyID) throws {
        try AudioUnitRemovePropertyListenerWithUserData(self, propertyID, listener.proc, listener.procInput).check()
    }

}

// MARK: - AudioUnit function validation

public extension OSStatus {

    func check() throws {
        if self != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: nil)
        }
    }

}
