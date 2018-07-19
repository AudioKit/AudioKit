//
//  AKMetronome.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Metronome Callback Ugen
public let callbackUgen =
    AKCustomUgen(name: "triggerFunction", argTypes: "f") { _, stack, userData in
        let trigger = stack.popFloat()
        if trigger != 0 {
            if let callback = userData as? AKCallback {
                callback()
            }
        }
        stack.push(trigger)
}

/// Useful metronome class that you can utilize for your own projects
public class AKMetronome: AKOperationGenerator {

    /// BPM
    public var tempo: Double = 60 { didSet { parameters[0] = tempo } }

    /// Number of clicks in one measure
    public var subdivision: Int = 4 { didSet { parameters[1] = Double(subdivision) } }

    /// First click sound frequency
    public var frequency1: Double = 2_000 { didSet { parameters[3] = frequency1 } }

    /// Non-first click sound frequency
    public var frequency2: Double = 1_000 { didSet { parameters[4] = frequency2 } }

    /// The value of the current beat
    public var currentBeat: Int {
        get { return 1 + Int((parameters[2] + 1).truncatingRemainder(dividingBy: Double(subdivision))) }
        set(newValue) { parameters[2] = Double(newValue) }
    }

    /// Function to perform on every tick
    public var callback: AKCallback {
        didSet {
            callbackUgen.userData = callback
        }
    }

    /// Initialize the metronome
    @objc public init() {

        let sporth = "(0 p) bpm2rate metro (_triggerFunction fe) dup 0.001 0.01 0.001 tenvx swap (1 p) 0 count dup 2 pset 0 eq (4 p) (3 p) branch 0.4 sine * dup"
        callback = { return }
        super.init(sporth: sporth, customUgens: [callbackUgen])
        parameters = [tempo, Double(subdivision), -1, frequency1, frequency2]
    }

    /// Reset the metronome
    public func reset() {
        currentBeat = -1
    }
}
