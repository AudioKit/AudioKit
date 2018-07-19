//
//  AKTuningTableBase.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

/// AKTuningTableBase provides low-level methods for creating arbitrary mappings of midi note numbers to musical frequencies
/// The default behavior is "12-tone equal temperament" so we can integrate in non-microtonal settings with backwards compatibility
@objc open class AKTuningTableBase: NSObject {

    // Definitions:
    // f = Frequency
    // p = Pitch = log2(frequency) for tunings where octave powers of 2
    // c = Cents = 1200 * Pitch
    // nn = midi note number of any tuning.  maps to frequency in this tuning table.

    // Regarding MIDI/Pitchbend ("etNNPitchBend") scheme:
    // etnn or 12ETNN = midi note number of 12ET.  1 12ETNN = 1 semitone = 100 cents
    // The greater your tolerance for numerical precision the less voice-stealing will happen with midi/pitchbend schemes

    /// For clarity, typealias Frequency as a Double
    public typealias Frequency = Double

    /// For clarify, typealias Cents as a Double.
    /// Cents = 1200 * log2(Frequency)
    public typealias Cents = Double

    /// Standard Nyquist frequency
    public static let NYQUIST: Frequency = AKSettings.sampleRate / 2

    /// Total number of MIDI Notes available to play
    @objc public static let midiNoteCount = 128

    internal var tableData = [Frequency](repeating: 1.0, count: midiNoteCount)

    /// Initialization for standard default 12 tone equal temperament
    @objc public override init() {
        super.init()
        for noteNumber in 0..<AKTuningTable.midiNoteCount {
            let f = 440 * exp2((noteNumber - 69) / 12)
            setFrequency(f, at: MIDINoteNumber(noteNumber) )
        }
    }

    /// Notes Per Octave: The count of the frequency array
    /// Defaults to 12 for the base class...should be overridden by subclasses
    @objc public var npo: Int {
        return 12
    }

    /// Return the Frequency for the given MIDINoteNumber
    @objc public func frequency(forNoteNumber noteNumber: MIDINoteNumber) -> Frequency {
        return tableData[Int(noteNumber)]
    }

    /// Set frequency of a given note number
    @objc public func setFrequency(_ frequency: Frequency, at noteNumber: MIDINoteNumber) {
        tableData[Int(noteNumber)] = frequency
    }
}
