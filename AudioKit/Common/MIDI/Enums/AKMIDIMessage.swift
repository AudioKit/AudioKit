//
//  AKMIDIMessage.swift
//  AudioKit
//
//  Created by Jeff Cooper on 3/26/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

// A basic container for a MIDI message, so that they can be used in different contexts
// by accessing .data: [UInt8] directly

public protocol AKMIDIMessage {
    var data: [UInt8] { get }
    var description: String { get }
}
