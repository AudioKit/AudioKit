//
//  AKPolyphonicNode.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/14/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

/// Bare bones implementation of AKPolyphonic protocol
@objc open class AKPolyphonicNode: AKNode, AKPolyphonic {

    /// Global tuning table used by AKPolyphonicNode (AKNode classes adopting AKPolyphonic protocol)
    @objc public static var tuningTable = AKTuningTable()
    open var midiInstrument: AVAudioUnitMIDIInstrument?

    /// Play a sound corresponding to a MIDI note with frequency
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    ///
    @objc open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        AKLog("Playing note: \(noteNumber), velocity: \(velocity), frequency: \(frequency), override in subclass")
    }

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    @objc open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {

        // MARK: Microtonal pitch lookup
        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        //        AKLog("Playing note: \(noteNumber), velocity: \(velocity), using tuning table frequency: \(frequency)")
        self.play(noteNumber: noteNumber, velocity: velocity, frequency: frequency)
    }

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    @objc open func stop(noteNumber: MIDINoteNumber) {
        AKLog("Stopping note \(noteNumber), override in subclass")
    }
}
