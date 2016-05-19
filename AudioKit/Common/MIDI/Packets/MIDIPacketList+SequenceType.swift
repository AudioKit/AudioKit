//
//  MIDIPacketList+SequenceType.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

extension MIDIPacketList: SequenceType {
    /// Type alis for MIDI Packet List Generator
    public typealias Generator = MIDIPacketListGenerator
    
    /// Create a generator from the packet list
    public func generate() -> Generator {
        return Generator(packetList: self)
    }
}