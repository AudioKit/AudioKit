//
//  Conductor.swift
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-01-19.
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
    var sampler: AKSampler

    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2

    var semitoneOffset = 0
    
    // Point this to wherever you keep your samples folder
    let baseURL = URL(fileURLWithPath: "/Users/shane/Desktop/Compressed Sounds")

    init() {

        // MIDI Configure
        midi.createVirtualPorts()
        midi.openInput("Session 1")
        midi.openOutput()

        // Session settings
        //AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .medium
        AKSettings.enableLogging = true

        // Signal Chain
        sampler = AKSampler()
        
        // Set up the AKSampler
        setupSampler()
        
        // Set Output & Start AudioKit
        AudioKit.output = sampler
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }
    }
    
    private func setupSampler()
    {
        // uncomment only one of the following two lines
        //sampler.loadCompressedFiles()
        sampler.loadSFZ()

        sampler.ampAttackTime = 0.01
        sampler.ampDecayTime = 0.1
        sampler.ampSustainLevel = 0.8
        sampler.ampReleaseTime = 0.5
        
//        sampler.filterEnable = true
//        sampler.filterCutoff = 20.0
//        sampler.filterAttackTime = 1.0
//        sampler.filterDecayTime = 1.0
//        sampler.filterSustainLevel = 0.5
//        sampler.filterReleaseTime = 10.0
    }
    
    private func loadCompressed(noteNumber: MIDINoteNumber, folderName: String, fileEnding: String,
                                min_note: Int32 = -1, max_note: Int32 = -1, min_vel: Int32 = -1, max_vel: Int32 = -1)
    {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        let sd = AKSampleDescriptor(noteNumber: Int32(noteNumber), noteHz: Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)), min_note: min_note, max_note: max_note, min_vel: min_vel, max_vel: max_vel, bLoop: true, fLoopStart: 0.0, fLoopEnd: 0.0, fStart: 0.0, fEnd: 0.0)
        sampler.loadCompressedSampleFile(sfd: AKSampleFileDescriptor(sd: sd, path: fileURL.path))
    }

    func addMIDIListener(_ listener: AKMIDIListener) {
        midi.addListener(listener)
    }

    func getMIDIInputNames() -> [String] {
        return midi.inputNames
    }

    func openMIDIInput(byName: String) {
        midi.closeAllInputs()
        midi.openInput(byName)
    }

    func openMIDIInput(byIndex: Int) {
        midi.closeAllInputs()
        midi.openInput(midi.inputNames[byIndex])
    }

    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        sampler.play(noteNumber: offsetNote(note, semitones: semitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        sampler.stop(noteNumber: offsetNote(note, semitones: semitoneOffset))
    }

    func allNotesOff() {
        for note in 0 ... 127 {
            sampler.silence(noteNumber: MIDINoteNumber(note))
        }
    }

    func afterTouch(_ pressure: MIDIByte) {
    }

    func controller(_ controller: MIDIByte, value: MIDIByte) {
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            if sampler.filterEnable {
                sampler.filterCutoff = 1 + 19 * Double(value) / 127.0
            } else {
                sampler.vibratoDepth = 0.5 * Double(value) / 127.0
            }
        case AKMIDIControl.damperOnOff.rawValue:
            sampler.sustainPedal(pedalDown: value != 0)
        default:
            break
        }
    }

    func pitchBend(_ pitchWheelValue: MIDIWord) {
        let pwValue = Double(pitchWheelValue)
        let scale = (pwValue - 8_192.0) / 8_192.0
        if scale >= 0.0 {
            sampler.pitchBend = scale * self.pitchBendUpSemitones
        } else {
            sampler.pitchBend = scale * self.pitchBendDownSemitones
        }
    }

}
