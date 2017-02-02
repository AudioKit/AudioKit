//
//  MIDIPacketList+SequenceType.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

extension MIDIPacketList: Sequence {
    public typealias Element = MIDIPacket

    public func makeIterator() -> AnyIterator<Element> {
        var first = packet
        let s = sequence(first: &first) { MIDIPacketNext($0) }
               .prefix(Int(numPackets)).makeIterator()
        return AnyIterator { s.next()?.pointee }
  }
}
