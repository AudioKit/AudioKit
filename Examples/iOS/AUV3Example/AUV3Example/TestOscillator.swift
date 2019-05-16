//
//  TestOscillator.swift
//  AUV3Example
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class TestOscillator {
    var osc = AKOscillatorBank(waveform: AKTable(.square))
    var booster = AKBooster()
    var output: AKNode {
        return booster
    }
    
    func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 100, channel: MIDIChannel = 0) {
        print("playing note \(noteNumber)")
        osc.play(noteNumber: noteNumber, velocity: velocity)
    }

    func setupRoute() {
        print("setting up testosc route")
        osc >>> booster
    }


}
