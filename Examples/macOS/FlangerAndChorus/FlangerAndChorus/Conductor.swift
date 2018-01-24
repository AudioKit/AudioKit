//
//  Conductor.swift
//  AKTest1
//
//  Created by Shane Dunne on 2018-01-19.
//  Copyright © 2018 Shane Dunne. All rights reserved.
//

import AudioKit

func Offset(_ note: MIDINoteNumber, semitones: Int) -> MIDINoteNumber {
    let nn = Int(note)
    return (MIDINoteNumber)(semitones + nn)
}

class Conductor {
    
    static let shared = Conductor()
    
    let midi = AKMIDI()
    var sampler:AKMIDISampler
    var samplerGain:AKBooster
    var flanger: AKFlanger
    var chorus: AKChorus
    
    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2
    
    var semitoneOffset = -12  // offset notes by this many semitones from MIDI note numbers

    init() {
        
        // MIDI Configure
        midi.createVirtualPorts()
        midi.openInput("Session 1")
        midi.openOutput()
        
        // Session settings
        //AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .medium
        AKSettings.enableLogging = false
        
        // Signal Chain
        sampler = AKMIDISampler()
        samplerGain = AKBooster(sampler)
        flanger = AKFlanger(samplerGain)
        chorus = AKChorus(flanger)

        // Set Output & Start AudioKit
        AudioKit.output = chorus
        do {
            try AudioKit.start()         
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        // Initial parameters setup: sampler
        // Comment out to use default sine waves -- useful for testing Chorus
        //useSamplerPreset("X50 Archi Prime File.aupreset")
        //samplerGain.gain = 5.0

        // Initial parameters setup: flanger
        flanger.frequency = 0.7
        flanger.depth = 0.4
        flanger.dryWetMix = 0.5
        flanger.feedback = -0.9

        // Initial parameters setup: chorus
        chorus.frequency = 0.7
        chorus.depth = 0.4
        chorus.dryWetMix = 0.25
        chorus.feedback = 0.0
    }
    
    func addMIDIListener(_ listener:AKMIDIListener) {
        midi.addListener(listener)
    }
    
    func getMIDIInputNames() -> [String] {
        return midi.inputNames
    }
    
    func openMIDIInput(byName:String) {
        midi.closeAllInputs()
        midi.openInput(byName)
    }
    
    func openMIDIInput(byIndex: Int) {
        midi.closeAllInputs()
        midi.openInput(midi.inputNames[byIndex])
    }
    
    // Example of loading e.g. an .exs or .aupreset. Set base path as you wish.
    func useSamplerPreset(_ presetName: String) {
        let presetPath = "/Users/shane/Desktop/Sounds/Sampler Instruments/\(presetName)"
        try! sampler.loadPath(presetPath)
    }
    
    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        sampler.play(noteNumber: Offset(note, semitones:semitoneOffset), velocity: velocity, channel: channel)
    }
    
    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        sampler.stop(noteNumber: Offset(note, semitones:semitoneOffset), channel: channel)
    }
    
    func allNotesOff() {
        for note in 0 ... 127 {
            sampler.stop(noteNumber: MIDINoteNumber(note), channel: 0)
        }
    }
    
    func afterTouch(_ pressure: MIDIByte) {
    }
    
    func controller(_ controller: MIDIByte, value: MIDIByte) {
        sampler.midiCC(controller, value: value, channel: 0)
    }

    func pitchBend(_ pitchWheelValue: MIDIWord) {
        let pwValue = Double(pitchWheelValue)
        let scale = (pwValue - 8192.0) / 8192.0
        if scale >= 0.0 {
            sampler.tuning = scale * self.pitchBendUpSemitones
        } else {
            sampler.tuning = scale * self.pitchBendDownSemitones
        }
    }

}
