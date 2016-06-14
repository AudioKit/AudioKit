//
//  MIDIPacketListGenerator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/// Generator for MIDIPacketList allowing iteration over its list of MIDIPacket objects.
public struct MIDIPacketListGenerator: IteratorProtocol {
    public typealias Element = MIDIPacket
    
    /// Initialize the packet list generator with a packet list
    ///
    /// - parameter packetList: MIDI Packet List
    ///
    init(packetList: MIDIPacketList) {
        let ptr = UnsafeMutablePointer<MIDIPacket>(allocatingCapacity: 1)
        ptr.initialize(with: packetList.packet)
        self.packet = ptr
        self.count = packetList.numPackets
    }
    
    /// Provide the next element (packet)
    public mutating func next() -> Element? {
        guard self.packet != nil && self.index < self.count else { return nil }
        
        let lastPacket = self.packet!
        self.packet = MIDIPacketNext(self.packet!)
        self.index += 1
        return lastPacket.pointee
    }
    
    // Extracted packet list info
    var count: UInt32
    var index: UInt32 = 0
    
    // Iteration state
    var packet: UnsafeMutablePointer<MIDIPacket>?
}
