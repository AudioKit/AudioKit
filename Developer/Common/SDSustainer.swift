//
//  Sustainer.swift
//  ExtendingAudioKit
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//
//  Wraps a reference to any AKPolyphonicNode and interprets play()/stop() as key up/down
//  together with state of a sustain pedal, to add pedal-sustain capability to nodes
//  which don't have their own.

import Foundation
import AudioKit

class SDSustainer {

    var instrument: AKPolyphonicNode
    var keyDown: [Bool]
    var isPlaying: [Bool]
    var pedalIsDown: Bool

    required init(_ node: AKPolyphonicNode) {
        instrument = node
        keyDown = [Bool]()
        isPlaying = [Bool]()
        for _ in 0 ... 127 {
            keyDown.append(false)
            isPlaying.append(false)
        }
        pedalIsDown = false
    }

    /// Key down
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        if pedalIsDown && keyDown[Int(noteNumber)] {
            instrument.stop(noteNumber: noteNumber)
        } else {
            keyDown[Int(noteNumber)] = true
        }
        instrument.play(noteNumber: noteNumber, velocity: velocity)
        isPlaying[Int(noteNumber)] = true
    }

    /// Key up
    open func stop(noteNumber: MIDINoteNumber) {
        if !pedalIsDown {
            instrument.stop(noteNumber: noteNumber)
            isPlaying[Int(noteNumber)] = false
        }
        keyDown[Int(noteNumber)] = false
    }

    // Sustain pedal
    open func sustain(down: Bool) {
        if down {
            pedalIsDown = true
        } else {
            for i in 0 ... 127 {
                if isPlaying[i] && !keyDown[i] {
                    instrument.stop(noteNumber: MIDINoteNumber(i))
                    keyDown[i] = false
                    isPlaying[i] = false
                }
            }
            pedalIsDown = false
        }
    }
}
