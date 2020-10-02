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
            defer {
                p = MIDIPacketNext(&p).pointee
                idx += 1
            }
            return p
        }
    }
}

#endif
