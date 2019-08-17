//
//  Conductor.swift
//  ExtendingAudioKit
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit

func offsetNote(_ note: MIDINoteNumber, semitones: Int) -> MIDINoteNumber {
    let nn = Int(note)
    return (MIDINoteNumber)(semitones + nn)
}

class Conductor {

    static let shared = Conductor()

    let midi = AKMIDI()
    var oscillator: AKOscillatorBank
    var sustainer: SDSustainer
    var oscillatorGain: SDBooster    // Your own extension AKNode!

    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2

    var synthSemitoneOffset = 0

    static let tableLength = 1_024
    let waveforms = [
        AKTable(.sine, count: tableLength),
        AKTable(.positiveTriangle, count: tableLength),
        AKTable(.square, count: tableLength),
        AKTable(.sawtooth, count: tableLength)
    ]
    var waveformIndex = 2

    init() {

        // MIDI Configure
        midi.createVirtualPorts()
        midi.openInput(name: "Session 1")
        midi.openOutput()

        // Session settings
        //AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .medium
        AKSettings.enableLogging = false

        // Signal Chain
        oscillator = AKOscillatorBank(waveform: waveforms[waveformIndex])
        sustainer = SDSustainer(oscillator)
        oscillatorGain = SDBooster(oscillator)

        // Set Output & Start AudioKit
        AudioKit.output = oscillatorGain
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }

        // Initial parameters setup: synth
        oscillator.attackDuration = 0.01
        oscillator.decayDuration = 0.01
        oscillator.sustainLevel = 0.8
        oscillator.releaseDuration = 0.25
        oscillator.vibratoDepth = 0.0
        oscillator.vibratoRate = 5

        // Initial parameters setup: levels
        oscillatorGain.gain = 1.0
    }

    func addMIDIListener(_ listener: AKMIDIListener) {
        midi.addListener(listener)
    }

    func getMIDIInputNames() -> [String] {
        return midi.inputNames
    }

    func openMIDIInput(byName: String) {
        midi.closeAllInputs()
        midi.openInput(name: byName)
    }

    func openMIDIInput(byIndex: Int) {
        midi.closeAllInputs()
        midi.openInput(index: byIndex)
    }

    func getWaveformName() -> String {
        let names = [ "Sine", "Triangle", "Square", "Sawtooth" ]
        return names[waveformIndex]
    }

    func setWaveformIndex(_ i: Int) {
        guard i >= 0 && i <= 3 else { return }
        if (i != waveformIndex) {
            waveformIndex = i
            AKLog("Change waveform to \(getWaveformName())")
            oscillator.waveform = waveforms[i]
        }
    }

    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        // key-up, key-down and pedal operations are mediated by SDSustainer
        sustainer.play(noteNumber: offsetNote(note, semitones: synthSemitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        // key-up, key-down and pedal operations are mediated by SDSustainer
        sustainer.stop(noteNumber: offsetNote(note, semitones: synthSemitoneOffset))
    }

    func allNotesOff() {
        for note in 0 ... 127 {
            sustainer.stop(noteNumber: MIDINoteNumber(note + synthSemitoneOffset))
        }
    }

    func aftertouch(_ pressure: MIDIByte) {
    }

    func controller(_ controller: MIDIByte, value: MIDIByte) {
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            oscillator.vibratoDepth = 0.5 * Double(value) / 128.0
        case AKMIDIControl.damperOnOff.rawValue:
            // key-up, key-down and pedal operations are mediated by SDSustainer
            sustainer.sustain(down: value != 0)
        default:
            break
        }
    }

    func pitchBend(_ pitchWheelValue: MIDIWord) {
        let pwValue = Double(pitchWheelValue)
        let scale = (pwValue - 8_192.0) / 8_192.0
        if scale >= 0.0 {
            oscillator.pitchBend = scale * self.pitchBendUpSemitones
        } else {
            oscillator.pitchBend = scale * self.pitchBendDownSemitones
        }
    }

}
