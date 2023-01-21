// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioToolbox
import Foundation

/// Helper for accessing the data of `MIDIMetaEvent`.
struct UnsafeMIDIMetaEventPointer {
    let event: UnsafePointer<MIDIMetaEvent>
    let payload: UnsafeBufferPointer<UInt8>

    init?(_ pointer: UnsafeRawBufferPointer) {
        guard let baseAddress = pointer.baseAddress else {
            return nil
        }
        self.init(baseAddress)
    }

    init?(_ pointer: UnsafeRawPointer?) {
        guard let pointer = pointer else {
            return nil
        }
        self.init(pointer)
    }

    init(_ pointer: UnsafeRawPointer) {
        let event = pointer.bindMemory(to: MIDIMetaEvent.self, capacity: 1)
        let offset = MemoryLayout<MIDIMetaEvent>.offset(of: \MIDIMetaEvent.data)!
        let dataLength = Int(event.pointee.dataLength)
        let dataPointer = pointer.advanced(by: offset).bindMemory(to: UInt8.self, capacity: dataLength)
        self.event = event
        payload = UnsafeBufferPointer(start: dataPointer, count: dataLength)
    }
}
