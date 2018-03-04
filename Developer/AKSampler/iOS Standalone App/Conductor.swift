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

    var synthSemitoneOffset = 0
    
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
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        
        // Download http://getdunne.com/download/TX_LoTine81z.zip
        // Put folder in your app's Documents folder:
        //   On a physical iOS device, use iTunes File Sharing and simply drag it in
        //   On simulator, look at the debug output to see the full path where the program is
        //      looking, and put the "TX LoTine81z" folder in there.
        // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
        let folderName = "TX LoTine81z"

        loadCompressed(noteNumber: 48, folderName: folderName, fileEnding: "_ms2_048_c2.wv", min_note: 0, max_note: 51, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 48, folderName: folderName, fileEnding: "_ms1_048_c2.wv", min_note: 0, max_note: 51, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 48, folderName: folderName, fileEnding: "_ms0_048_c2.wv", min_note: 0, max_note: 51, min_vel: 87, max_vel: 127)
        
        loadCompressed(noteNumber: 54, folderName: folderName, fileEnding: "_ms2_054_f#2.wv", min_note: 52, max_note: 57, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 54, folderName: folderName, fileEnding: "_ms1_054_f#2.wv", min_note: 52, max_note: 57, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 54, folderName: folderName, fileEnding: "_ms0_054_f#2.wv", min_note: 52, max_note: 57, min_vel: 87, max_vel: 127)

        loadCompressed(noteNumber: 60, folderName: folderName, fileEnding: "_ms2_060_c3.wv", min_note: 58, max_note: 63, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 60, folderName: folderName, fileEnding: "_ms1_060_c3.wv", min_note: 58, max_note: 63, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 60, folderName: folderName, fileEnding: "_ms0_060_c3.wv", min_note: 58, max_note: 63, min_vel: 87, max_vel: 127)
        
        loadCompressed(noteNumber: 66, folderName: folderName, fileEnding: "_ms2_066_f#3.wv", min_note: 64, max_note: 69, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 66, folderName: folderName, fileEnding: "_ms1_066_f#3.wv", min_note: 64, max_note: 69, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 66, folderName: folderName, fileEnding: "_ms0_066_f#3.wv", min_note: 64, max_note: 69, min_vel: 87, max_vel: 127)

        loadCompressed(noteNumber: 72, folderName: folderName, fileEnding: "_ms2_072_c4.wv", min_note: 70, max_note: 75, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 72, folderName: folderName, fileEnding: "_ms1_072_c4.wv", min_note: 70, max_note: 75, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 72, folderName: folderName, fileEnding: "_ms0_072_c4.wv", min_note: 70, max_note: 75, min_vel: 87, max_vel: 127)
        
        loadCompressed(noteNumber: 78, folderName: folderName, fileEnding: "_ms2_078_f#4.wv", min_note: 76, max_note: 81, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 78, folderName: folderName, fileEnding: "_ms1_078_f#4.wv", min_note: 76, max_note: 81, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 78, folderName: folderName, fileEnding: "_ms0_078_f#4.wv", min_note: 76, max_note: 81, min_vel: 87, max_vel: 127)
        
        loadCompressed(noteNumber: 84, folderName: folderName, fileEnding: "_ms2_084_c5.wv", min_note: 82, max_note: 127, min_vel: 0, max_vel: 43)
        loadCompressed(noteNumber: 84, folderName: folderName, fileEnding: "_ms1_084_c5.wv", min_note: 82, max_note: 127, min_vel: 44, max_vel: 86)
        loadCompressed(noteNumber: 84, folderName: folderName, fileEnding: "_ms0_084_c5.wv", min_note: 82, max_note: 127, min_vel: 87, max_vel: 127)

        sampler.buildKeyMap()
        
        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")

        sampler.ampAttackTime = 0.01
        sampler.ampDecayTime = 0.1
        sampler.ampSustainLevel = 0.8
        sampler.ampReleaseTime = 0.5
        
        // per-voice filter is still experimental and buggy
//        sampler.filterEnable = true
//        sampler.filterAttackTime = 1.0
//        sampler.filterDecayTime = 1.0
//        sampler.filterSustainLevel = 0.5
//        sampler.filterReleaseTime = 10.0
    }

    private func loadCompressed(noteNumber: MIDINoteNumber, folderName: String, fileEnding: String,
                                min_note: Int32 = -1, max_note: Int32 = -1, min_vel: Int32 = -1, max_vel: Int32 = -1)
    {
        let folderURL = FileManagerUtils.shared.getDocsUrl(folderName)
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
        sampler.play(noteNumber: offsetNote(note, semitones: synthSemitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        sampler.stop(noteNumber: offsetNote(note, semitones: synthSemitoneOffset))
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
            sampler.vibratoDepth = 0.5 * Double(value) / 128.0
            
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
