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
    var filter = AKMoogLadder()
    var volume = AKBooster()
    var tempo: Double = 120.0
    var hostTempo: Double = 120.0
    var parameterTree: AUParameterTree
    let volumeControl = AUParameter(
        identifier: "volumeControl",
        name: "Volume",
        address: 0,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)
    let filterRange = 20.0...20000.0
    let filterTaper = 3.3
    let filterControl = AUParameter(
        identifier: "filterFreq",
        name: "Filter Cutoff",
        address: 1,
        range: 0...1.0,
        unit: .generic,
        flags: .default)

    init() {
        parameterTree = AUParameterTree(children: [volumeControl, filterControl])
        createParameterSetters()
        createParameterGetters()
        createParameterDisplays()
        setDefaultAuValues()
    }

    func setDefaultAuValues() {
        volumeControl.value = 0.666
        filterControl.value = 1.0
    }

    private func createParameterSetters() {
        parameterTree.implementorValueObserver = { param, floatValue in
            let value = Double(floatValue)
            if param == self.volumeControl {
                self.volume.gain = value
            }
            if param == self.filterControl {
                let denorm = value.denormalized(to: self.filterRange, taper: self.filterTaper)
                self.filter.cutoffFrequency = denorm
            }
            // if param == other values here...
        }
    }
    private func createParameterGetters() {
        parameterTree.implementorValueProvider = { param in
            if param == self.volumeControl {
                return AUValue(self.volume.gain)
            }
            if param == self.filterControl {
                let val = self.filter.cutoffFrequency.normalized(from: self.filterRange, taper: self.filterTaper)
                return AUValue(val)
            }
            // if param == other values here...
            return 0
        }
    }
    private func createParameterDisplays() {
        parameterTree.implementorStringFromValueCallback = { param, value in
            if let floatValue = value?.pointee {
                if param == self.volumeControl {
                    return String(format: "%.2f", floatValue)
                }
                if param == self.filterControl {
                    let denorm = Double(floatValue).denormalized(to: self.filterRange, taper: self.filterTaper)
                    return String(format: "%.3f Hz", AUValue(denorm))
                }
                // if param == other values here...
            }
            return String(format: "%.3f", value?.pointee ?? 0)
        }
    }

    func start() {
        try? AudioKit.start()
    }

    func setupRoute() {
        osc >>> filter
        filter >>> volume
        AudioKit.output = volume
    }

    func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 100) {
        osc.play(noteNumber: noteNumber, velocity: velocity)
    }
    func stop(noteNumber: MIDINoteNumber) {
        osc.stop(noteNumber: noteNumber)
    }
}
