//
//  MIDIPacketList+SequenceType.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 4/29/16.
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