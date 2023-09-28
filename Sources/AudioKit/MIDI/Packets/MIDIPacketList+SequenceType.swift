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

        withUnsafePointer(to: packet) { ptr in
            var p = ptr
            var idx: UInt32 = 0

            return AnyIterator {
                guard idx < self.numPackets else {
                    return nil
                }

                idx += 1
                let packet = extractPacket(p)
                p = UnsafePointer(MIDIPacketNext(p))
                return packet
            }
        }
    }
}

/// We can't call pointee on a packet pointer without potentially reading off the end and
/// triggering ASAN. Instead extract the data.
public func extractPacketData(_ ptr: UnsafePointer<MIDIPacket>) -> [UInt8] {

    let raw = UnsafeRawPointer(ptr)
    let dataPtr = raw.advanced(by: MemoryLayout.offset(of: \MIDIPacket.data)!)

    let length = Int(raw.loadUnaligned(fromByteOffset: MemoryLayout.offset(of: \MIDIPacket.length)!,
                                       as: UInt16.self))

    var array = [UInt8](repeating: 0, count: length)
    memcpy(&array, dataPtr, length)

    return array
}

/// We can't call pointee on a packet pointer without potentially reading off the end and
/// triggering ASAN.
///
/// This is not ideal. We're using MIDIPacket directly and assuming that our packet length is less
/// than the 256 bytes in MIDIPacket.
public func extractPacket(_ ptr: UnsafePointer<MIDIPacket>) -> MIDIPacket? {

    var packet = MIDIPacket()
    let raw = UnsafeRawPointer(ptr)

    let length = raw.loadUnaligned(fromByteOffset: MemoryLayout.offset(of: \MIDIPacket.length)!,
                                   as: UInt16.self)

    // We can't represent a longer packet as a MIDIPacket value.
    if length > 256 {
        return nil
    }

    packet.length = length
    packet.timeStamp = raw.loadUnaligned(fromByteOffset: MemoryLayout.offset(of: \MIDIPacket.timeStamp)!,
                                         as: MIDITimeStamp.self)

    let dataPtr = raw.advanced(by: MemoryLayout.offset(of: \MIDIPacket.data)!)
    _ = withUnsafeMutableBytes(of: &packet.data) { ptr in
        memcpy(ptr.baseAddress!, dataPtr, Int(length))
    }

    return packet
}

#endif
