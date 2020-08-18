// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AVFoundation

extension MIDIMetaEvent {
    /// `MIDIMetaEvent` is a variable length C structure. YOU MUST create one using this function
    ///  if the data is of length > 0.
    /// - Parameters:
    ///   - metaEventType: type of event
    ///   - data: event data
    /// - Returns: pointer to allocated event.
    static func allocate(metaEventType: UInt8, data: [UInt8]) -> UnsafeMutablePointer<MIDIMetaEvent> {

        let size = MemoryLayout<MIDIMetaEvent>.size + data.count
        let mem = UnsafeMutableRawPointer.allocate(byteCount: size,
                                                   alignment: MemoryLayout<Int8>.alignment)
        let ptr = mem.bindMemory(to: MIDIMetaEvent.self, capacity: 1)

        ptr.pointee.metaEventType = metaEventType
        ptr.pointee.dataLength = UInt32(data.count)

        withUnsafeMutablePointer(to: &ptr.pointee.data, { pointer in
            for i in 0 ..< data.count {
                pointer[i] = data[i]
            }
        })

        return ptr
    }
}
