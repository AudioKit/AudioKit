//
//  MIDIPacketList+SequenceType.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import CoreMIDI

extension MIDIPacketList: Sequence {
    public typealias Element = MIDIPacket

    public var count: UInt32 {
        return self.numPackets
    }

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
