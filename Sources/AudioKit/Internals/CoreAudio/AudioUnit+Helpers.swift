// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS)

import AVFoundation
import CoreAudio

// MARK: - AudioUnit helpers

/// Get, set, and listen to properties
public extension AudioUnit {
    /// Get value for a property
    func getValue<T>(forProperty property: AudioUnitPropertyID) throws -> T {
        let (dataSize, _) = try getPropertyInfo(propertyID: property)
        return try getProperty(propertyID: property, dataSize: dataSize)
    }

    /// Set value for a property
    func setValue<T>(value: T, forProperty property: AudioUnitPropertyID) throws {
        let (dataSize, _) = try getPropertyInfo(propertyID: property)
        return try setProperty(propertyID: property, dataSize: dataSize, data: value)
    }

    /// Add a listener to a property
    func add(listener: AudioUnitPropertyListener, toProperty property: AudioUnitPropertyID) throws {
        do {
            try addPropertyListener(listener: listener, toProperty: property)
        } catch {
            Log("Error Adding Property Listener")
            throw error
        }
    }

    /// Remove a listener from a property
    func remove(listener: AudioUnitPropertyListener, fromProperty property: AudioUnitPropertyID) {
        do {
            try removePropertyListener(listener: listener, fromProperty: property)
        } catch {
            Log("Error Removing Property Listener")
        }
    }
}

// MARK: - AudioUnit callbacks

/// Listener to properties in an audio unit
public struct AudioUnitPropertyListener {
    /// Property listener callback type
    public typealias AudioUnitPropertyListenerCallback = (
        _ audioUnit: AudioUnit,
        _ property: AudioUnitPropertyID
    ) -> Void

    let proc: AudioUnitPropertyListenerProc
    let procInput: UnsafeMutablePointer<AudioUnitPropertyListenerCallback>

    /// Initialize the listener with a callback
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

/// Extension for getting and setting properties
public extension AudioUnit {
    /// Get property information
    func getPropertyInfo(propertyID: AudioUnitPropertyID) throws -> (dataSize: UInt32, writable: Bool) {
        var dataSize: UInt32 = 0
        var writable: DarwinBoolean = false

        try AudioUnitGetPropertyInfo(self, propertyID, kAudioUnitScope_Global, 0, &dataSize, &writable).check()

        return (dataSize: dataSize, writable: writable.boolValue)
    }

    /// Get property
    func getProperty<T>(propertyID: AudioUnitPropertyID, dataSize: UInt32) throws -> T {
        var dataSize = dataSize
        let data = UnsafeMutablePointer<T>.allocate(capacity: Int(dataSize))
        defer {
            data.deallocate()
        }

        try AudioUnitGetProperty(self, propertyID, kAudioUnitScope_Global, 0, data, &dataSize).check()

        return data.pointee
    }

    /// Set a property
    func setProperty<T>(propertyID: AudioUnitPropertyID, dataSize: UInt32, data: T) throws {
        var data = data

        try AudioFileSetProperty(self, propertyID, dataSize, &data).check()
    }

    /// Add property listener
    /// - Parameters:
    ///   - listener: Listener to add
    ///   - propertyID: Property to listen to
    /// - Throws: Error if could not add property listener
    internal func addPropertyListener(listener: AudioUnitPropertyListener,
                                      toProperty propertyID: AudioUnitPropertyID) throws {
        try AudioUnitAddPropertyListener(self, propertyID, listener.proc, listener.procInput).check()
    }

    /// Remove property listener
    /// - Parameters:
    ///   - listener: Listener to remove
    ///   - propertyID: Property to listen to
    /// - Throws: Error if could not remove property listener
    internal func removePropertyListener(listener: AudioUnitPropertyListener,
                                         fromProperty propertyID: AudioUnitPropertyID) throws {
        try AudioUnitRemovePropertyListenerWithUserData(self, propertyID, listener.proc, listener.procInput).check()
    }
}

// MARK: - AudioUnit function validation

/// Extension to add a check function
public extension OSStatus {
    /// Check for and throw an error
    func check() throws {
        if self != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: nil)
        }
    }
}

#endif
