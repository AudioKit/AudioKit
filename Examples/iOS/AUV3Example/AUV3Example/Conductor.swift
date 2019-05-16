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
    var volume = AKBooster()
    var parameterTree: AUParameterTree
    let volumeControl = AUParameter(
        identifier: "volumeControl",
        name: "Volume",
        address: 0,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    init() {
        parameterTree = AUParameterTree(children: [volumeControl])
        createParameterSetters()
        createParameterGetters()
        createParameterDisplays()
        setDefaultValues()
    }

    func setDefaultValues() {
        volumeControl.value = 0.30
    }

    private func createParameterSetters() {
        parameterTree.implementorValueObserver = { param, floatValue in
            let value = Double(floatValue)
            if param == self.volumeControl {
                self.volume.gain = value
                print("volume set to \(value)")
            }
            // if param == other values here...
        }
    }
    private func createParameterGetters() {
        parameterTree.implementorValueProvider = { param in
            if param == self.volumeControl {
                return AUValue(self.volume.gain)
            }
            // if param == other values here...
            return 0
        }
    }
    private func createParameterDisplays() {
        parameterTree.implementorStringFromValueCallback = { param, value in
            if let floatValue = value?.pointee {
                if param == self.volumeControl {
                    return String(format: "%.3f", floatValue)
                }
            }
            // if param == other values here...
            return String(format: "%.3f", value?.pointee ?? 0)
        }
    }

    func start() {
        try? AudioKit.start()
    }

    func setupRoute() {
        osc >>> volume
        AudioKit.output = volume
    }

    func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 100) {
        osc.play(noteNumber: noteNumber, velocity: velocity)
    }
    func stop(noteNumber: MIDINoteNumber) {
        osc.stop(noteNumber: noteNumber)
    }
}
