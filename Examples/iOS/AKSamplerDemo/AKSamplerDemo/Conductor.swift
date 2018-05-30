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

    private func setupSampler() {
        // Example (below) of loading compressed sample files without a SFZ file
        //loadAndMapCompressedSampleFiles()

        // Preferred method: use SFZ file
        // You can download a small set of ready-to-use SFZ files and samples from
        // http://audiokit.io/downloads/ROMPlayerInstruments.zip
        // see loadSamples(byIndex:) below

        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.1
        sampler.sustainLevel = 0.8
        sampler.releaseDuration = 0.5

//        sampler.filterEnable = true
//        sampler.filterCutoff = 20.0
//        sampler.filterAttackDuration = 1.0
//        sampler.filterDecayDuration = 1.0
//        sampler.filterSustainLevel = 0.5
//        sampler.filterReleaseDuration = 10.0
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

    func loadSamples(byIndex: Int) {
        if byIndex < 0 || byIndex > 3 { return }

        let info = ProcessInfo.processInfo
        let begin = info.systemUptime

        let folderURL = FileManagerUtils.shared.getDocsUrl("ROMPlayer Instruments")
        let sfzFiles = [ "TX Brass.sfz", "TX LoTine81z.sfz", "TX Metalimba.sfz", "TX Pluck Bass.sfz" ]
        sampler.loadSFZ(path: folderURL.path, fileName: sfzFiles[byIndex])

        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")
    }

    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        sampler.play(noteNumber: offsetNote(note, semitones: synthSemitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        sampler.stop(noteNumber: offsetNote(note, semitones: synthSemitoneOffset))
    }

    func allNotesOff() {
        sampler.stopAllVoices()
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

extension Conductor {
    private func loadCompressed(noteNumber: MIDINoteNumber,
                                folderName: String,
                                fileEnding: String,
                                minimumNoteNumber: Int32 = -1,
                                maximumNoteNumber: Int32 = -1,
                                minimumVelocity: Int32 = -1,
                                maximumVelocity: Int32 = -1) {
        let folderURL = FileManagerUtils.shared.getDocsUrl(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        let sd = AKSampleDescriptor(noteNumber: Int32(noteNumber),
                                    noteFrequency: Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)),
                                    minimumNoteNumber: minimumNoteNumber,
                                    maximumNoteNumber: maximumNoteNumber,
                                    minimumVelocity: minimumVelocity,
                                    maximumVelocity: maximumVelocity,
                                    isLooping: true, // test looping based on fractional start/end values
                                    loopStartPoint: 0.2,
                                    loopEndPoint: 0.3,
                                    startPoint: 0.0,
                                    endPoint: 0.0)
        sampler.loadCompressedSampleFile(from: AKSampleFileDescriptor(sampleDescriptor: sd, path: fileURL.path))
    }

    func loadAndMapCompressedSampleFiles() {
        // Download http://audiokit.io/downloads/TX_LoTine81z.zip
        // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
        // Uncompress and put into your app's Documents folder.
        let folderName = "TX LoTine81z"

        loadCompressed(noteNumber: 48, folderName: folderName, fileEnding: "_ms2_048_c2.wv", minimumNoteNumber: 0, maximumNoteNumber: 51, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 48, folderName: folderName, fileEnding: "_ms1_048_c2.wv", minimumNoteNumber: 0, maximumNoteNumber: 51, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 48, folderName: folderName, fileEnding: "_ms0_048_c2.wv", minimumNoteNumber: 0, maximumNoteNumber: 51, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(noteNumber: 54, folderName: folderName, fileEnding: "_ms2_054_f#2.wv", minimumNoteNumber: 52, maximumNoteNumber: 57, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 54, folderName: folderName, fileEnding: "_ms1_054_f#2.wv", minimumNoteNumber: 52, maximumNoteNumber: 57, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 54, folderName: folderName, fileEnding: "_ms0_054_f#2.wv", minimumNoteNumber: 52, maximumNoteNumber: 57, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(noteNumber: 60, folderName: folderName, fileEnding: "_ms2_060_c3.wv", minimumNoteNumber: 58, maximumNoteNumber: 63, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 60, folderName: folderName, fileEnding: "_ms1_060_c3.wv", minimumNoteNumber: 58, maximumNoteNumber: 63, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 60, folderName: folderName, fileEnding: "_ms0_060_c3.wv", minimumNoteNumber: 58, maximumNoteNumber: 63, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(noteNumber: 66, folderName: folderName, fileEnding: "_ms2_066_f#3.wv", minimumNoteNumber: 64, maximumNoteNumber: 69, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 66, folderName: folderName, fileEnding: "_ms1_066_f#3.wv", minimumNoteNumber: 64, maximumNoteNumber: 69, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 66, folderName: folderName, fileEnding: "_ms0_066_f#3.wv", minimumNoteNumber: 64, maximumNoteNumber: 69, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(noteNumber: 72, folderName: folderName, fileEnding: "_ms2_072_c4.wv", minimumNoteNumber: 70, maximumNoteNumber: 75, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 72, folderName: folderName, fileEnding: "_ms1_072_c4.wv", minimumNoteNumber: 70, maximumNoteNumber: 75, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 72, folderName: folderName, fileEnding: "_ms0_072_c4.wv", minimumNoteNumber: 70, maximumNoteNumber: 75, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(noteNumber: 78, folderName: folderName, fileEnding: "_ms2_078_f#4.wv", minimumNoteNumber: 76, maximumNoteNumber: 81, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 78, folderName: folderName, fileEnding: "_ms1_078_f#4.wv", minimumNoteNumber: 76, maximumNoteNumber: 81, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 78, folderName: folderName, fileEnding: "_ms0_078_f#4.wv", minimumNoteNumber: 76, maximumNoteNumber: 81, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(noteNumber: 84, folderName: folderName, fileEnding: "_ms2_084_c5.wv", minimumNoteNumber: 82, maximumNoteNumber: 127, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(noteNumber: 84, folderName: folderName, fileEnding: "_ms1_084_c5.wv", minimumNoteNumber: 82, maximumNoteNumber: 127, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(noteNumber: 84, folderName: folderName, fileEnding: "_ms0_084_c5.wv", minimumNoteNumber: 82, maximumNoteNumber: 127, minimumVelocity: 87, maximumVelocity: 127)

        sampler.buildKeyMap()
    }
}
