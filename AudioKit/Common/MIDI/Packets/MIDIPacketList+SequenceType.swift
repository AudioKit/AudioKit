//
//  MIDIPacketList+SequenceType.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

extension MIDIPacketList: Sequence {
    /// Type alis for MIDI Packet List Generator
    public typealias Element = MIDIPacket
    /// Create a generator from the packet list
    public func makeIterator() -> AnyIterator<Element> {
      var i = 0
      var ptr = UnsafeMutablePointer<Element>.allocate(capacity: 1)
      ptr.initialize(to: packet)

      return AnyIterator {
          guard i < Int(self.numPackets) else {
            ptr.deallocate(capacity: 1)
            return nil
          }

          defer {
            ptr = MIDIPacketNext(ptr)
            i += 1
          }
          return ptr.pointee
      }
    }
}
