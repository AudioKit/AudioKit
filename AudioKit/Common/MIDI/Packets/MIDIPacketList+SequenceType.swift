//
//  MIDIPacketList+SequenceType.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

extension MIDIPacketList: Sequence {
    /// Type alis for MIDI Packet List Generator
    public typealias Iterator = MIDIPacketListGenerator
    
    /// Create a generator from the packet list
    public func makeIterator() -> Iterator {
        return Iterator(packetList: self)
    }
}
