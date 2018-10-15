//
//  AKSequenceable.swift
//  SequencerTest
//
//  Created by Jeff Cooper on 10/14/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public protocol AKSequenceable {
    var acceptsNote: Bool { get }
    var acceptsConrolChange: Bool { get }
    var acceptsProgramChange: Bool { get }
    var acceptsSysex: Bool { get }
    var validCCs: [MIDIByte] { get }
    var validNoteRange: ClosedRange<MIDINoteNumber> { get }
}

extension AKSequenceable {
    public var acceptsNote: Bool { return false }
    public var acceptsConrolChange: Bool { return false }
    public var acceptsProgramChange: Bool { return false }
    public var acceptsSysex: Bool { return false }
    public var validCCs: [MIDIByte] { return [MIDIByte]() }
    public var validNoteRange: ClosedRange<MIDINoteNumber> { return 0...127 }
}
