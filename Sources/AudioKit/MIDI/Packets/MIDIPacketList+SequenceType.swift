// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI

extension MIDIPacketList: Sequence {
    /// The element is a packet list sequence is a MIDI Packet
    public typealias Element = MIDIPacket

    /// Number of packets
    public var count: UInt32 {
        return self.numPackets
    }

    /// Create the sequence
    /// - Returns: Iterator of elements
    public func makeIterator() -> AnyIterator<Element> {
        var p: MIDIPacket = packet
        var idx: UInt32 = 0

        return AnyIterator {
            guard idx < self.numPackets else {
                return nil
            }

            if idx != 0 {
                p = MIDIPacketNext(&p).pointee
            }
            idx += 1
            
            return p
        }
    }
}

/// We can't call pointee on a packet pointer without potentially reading off the end and
/// triggering ASAN. Instead extract the data.
public func extractPacketData(_ ptr: UnsafePointer<MIDIPacket>) -> [UInt8] {

    let raw = UnsafeRawPointer(ptr)
    let lengthPtr = raw.advanced(by: MemoryLayout.offset(of: \MIDIPacket.length)!)
    let dataPtr = raw.advanced(by: MemoryLayout.offset(of: \MIDIPacket.data)!)

    let length = lengthPtr.withMemoryRebound(to: UInt16.self, capacity: 1) { pointer in
        Int(pointer.pointee)
    }

    var array = [UInt8](repeating: 0, count: length)
    memcpy(&array, dataPtr, length)

    return array
}

#endif
