//
//  Conductor.swift
//  AUV3Example
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class Conductor {
    var osc = AKOscillatorBank(waveform: AKTable(.square))
    var booster = AKBooster()

    func start() {
        try? AudioKit.start()
    }

    func setupRoute() {
        osc >>> booster
        AudioKit.output = booster
    }

    func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 100) {
        osc.play(noteNumber: noteNumber, velocity: velocity)
    }
    func stop(noteNumber: MIDINoteNumber) {
        osc.stop(noteNumber: noteNumber)
    }
}
