//
//  Conductor.swift
//  AKTest1
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2018 Shane Dunne. All rights reserved.
//

import AudioKit

func OffsetNote(_ note: MIDINoteNumber, semitones: Int) -> MIDINoteNumber {
    let nn = Int(note)
    return (MIDINoteNumber)(semitones + nn)
}

class Conductor {

    static let shared = Conductor()

    let midi = AKMIDI()
    var oscillator: AKOscillatorBank
    var flanger: AKFlanger
    var chorus: AKChorus

    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2

    var semitoneOffset = -12  // offset notes by this many semitones from MIDI note numbers

    static let tableLength = 1_024
    let waveforms = [
        AKTable(.sine, count: tableLength),
        AKTable(.positiveTriangle, count: tableLength),
        AKTable(.square, count: tableLength),
        AKTable(.sawtooth, count: tableLength)
    ]
    var waveformIndex = 3

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
        flanger = AKFlanger(oscillator)
        chorus = AKChorus(flanger)

        // Set Output & Start AudioKit
        AudioKit.output = chorus
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        // Initial parameters setup: synth
        oscillator.attackDuration = 0.01
        oscillator.decayDuration = 0.01
        oscillator.sustainLevel = 0.8
        oscillator.releaseDuration = 0.25
        oscillator.vibratoDepth = 0.0
        oscillator.vibratoRate = 5

        // Initial parameters setup: flanger
        flanger.frequency = 2.0
        flanger.depth = 0.4
        flanger.dryWetMix = 0.5
        flanger.feedback = -0.9

        // Initial parameters setup: chorus
        chorus.frequency = 0.7
        chorus.depth = 0.4
        chorus.dryWetMix = 0.25
        chorus.feedback = 0.0
    }

    func addMIDIListener(_ listener: AKMIDIListener) {
        midi.addListener(listener)
    }

    func getMIDIInputNames() -> [String] {
        return midi.inputNames
    }

    func openMIDIInput(name: String) {
        midi.closeAllInputs()
        midi.openInput(name: name)
    }

    func openMIDIInput(at index: Int) {
        midi.closeAllInputs()
        midi.openInput(index: index)
    }

    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        oscillator.play(noteNumber: OffsetNote(note, semitones: semitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        oscillator.stop(noteNumber: OffsetNote(note, semitones: semitoneOffset))
    }

    func allNotesOff() {
        for note in 0 ... 127 {
            oscillator.stop(noteNumber: MIDINoteNumber(note))
        }
    }

    func aftertouch(_ pressure: MIDIByte) {
    }

    func controller(_ controller: MIDIByte, value: MIDIByte) {
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            oscillator.vibratoDepth = 0.5 * Double(value) / 128.0
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
