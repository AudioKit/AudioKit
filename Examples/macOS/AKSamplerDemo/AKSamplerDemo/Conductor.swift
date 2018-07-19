//
//  Conductor.swift
//  AKSamplerDemo
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

    var semitoneOffset = 0

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
        sampler.loadSFZ(path: "/Users/shane/Downloads/ROMPlayer Instruments", fileName: "TX Brass.sfz")

        // Illustration of how to load single-cycle waveforms
        // See https://www.adventurekid.se/akrt/waveforms/ to obtain the "AdventureKid" WAV files.
//        do {
//            let path = "/Users/shane/Desktop/AKWF Samples/AKWF_bw_sawbright/AKWF_bsaw_0005.wav"
//            let furl = URL(fileURLWithPath: path)
//            let file = try AKAudioFile(forReading: furl)
//            let desc = AKSampleDescriptor(noteNumber: 26, noteHz: 44100.0/600,
//                                          min_note: 0, max_note: 127, min_vel: 0, max_vel: 127,
//                                          bLoop: true, fLoopStart: 0.0, fLoopEnd: 1.0, fStart: 0.0, fEnd: 0.0)
//            sampler.loadAKAudioFile(sd: desc, file: file)
//        } catch {
//            print("\(error.localizedDescription)")
//        }
//        sampler.setLoop(thruRelease: true)
//        sampler.buildSimpleKeyMap()

        // illustration of how to create a single-cycle waveform programmatically in Swift
//        var myData = [Float](repeating: 0.0, count: 1000)
//        for i in 0..<1000 {
//            myData[i] = sin(2.0 * Float(i)/1000 * Float.pi)
//        }
//        let sampleRate = Float(AKSettings.sampleRate)
//        let desc = AKSampleDescriptor(noteNumber: 69, noteHz: sampleRate/1000, min_note: -1, max_note: -1, min_vel: -1, max_vel: -1, bLoop: true, fLoopStart: 0, fLoopEnd: 1, fStart: 0, fEnd: 0)
//        let ptr = UnsafeMutablePointer<Float>(mutating: myData)
//        let ddesc = AKSampleDataDescriptor(sd: desc, sampleRateHz: sampleRate, bInterleaved: false, nChannels: 1, nSamples: 1000, pData: ptr)
//        sampler.loadRawSampleData(sdd: ddesc)
//        sampler.setLoop(thruRelease: true)
//        sampler.buildSimpleKeyMap()

        // Set up the main amplitude envelope
        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.1
        sampler.sustainLevel = 0.8
        sampler.releaseDuration = 0.5

        // optionally, enable the per-voice filters and set up the filter envelope
        // (Try this with the AdventrueKid sawtooth waveform example above)
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

    func loadSfz(folderPath: String, sfzFileName: String) {
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime

        sampler.betterLoadUsingSfzFile(folderPath: folderPath, sfzFileName: sfzFileName)

        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")
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

extension Conductor {
    private func loadCompressed(baseURL: URL,
                                noteNumber: MIDINoteNumber,
                                folderName: String,
                                fileEnding: String,
                                minimumNoteNumber: Int32 = -1,
                                maximumNoteNumber: Int32 = -1,
                                minimumVelocity: Int32 = -1,
                                maximumVelocity: Int32 = -1) {
        let folderURL = baseURL.appendingPathComponent(folderName)
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
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime

        // Download http://audiokit.io/downloads/TX_LoTine81z.zip
        // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
        // Uncompress and put folder inside wherever baseURL (see above) points

        let baseURL = URL(fileURLWithPath: "/Users/shane/Desktop/Compressed Sounds")
        let folderName = "TX LoTine81z"

        loadCompressed(baseURL: baseURL, noteNumber: 48, folderName: folderName, fileEnding: "_ms2_048_c2.wv", minimumNoteNumber: 0, maximumNoteNumber: 51, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 48, folderName: folderName, fileEnding: "_ms1_048_c2.wv", minimumNoteNumber: 0, maximumNoteNumber: 51, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 48, folderName: folderName, fileEnding: "_ms0_048_c2.wv", minimumNoteNumber: 0, maximumNoteNumber: 51, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 54, folderName: folderName, fileEnding: "_ms2_054_f#2.wv", minimumNoteNumber: 52, maximumNoteNumber: 57, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 54, folderName: folderName, fileEnding: "_ms1_054_f#2.wv", minimumNoteNumber: 52, maximumNoteNumber: 57, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 54, folderName: folderName, fileEnding: "_ms0_054_f#2.wv", minimumNoteNumber: 52, maximumNoteNumber: 57, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 60, folderName: folderName, fileEnding: "_ms2_060_c3.wv", minimumNoteNumber: 58, maximumNoteNumber: 63, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 60, folderName: folderName, fileEnding: "_ms1_060_c3.wv", minimumNoteNumber: 58, maximumNoteNumber: 63, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 60, folderName: folderName, fileEnding: "_ms0_060_c3.wv", minimumNoteNumber: 58, maximumNoteNumber: 63, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 66, folderName: folderName, fileEnding: "_ms2_066_f#3.wv", minimumNoteNumber: 64, maximumNoteNumber: 69, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 66, folderName: folderName, fileEnding: "_ms1_066_f#3.wv", minimumNoteNumber: 64, maximumNoteNumber: 69, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 66, folderName: folderName, fileEnding: "_ms0_066_f#3.wv", minimumNoteNumber: 64, maximumNoteNumber: 69, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 72, folderName: folderName, fileEnding: "_ms2_072_c4.wv", minimumNoteNumber: 70, maximumNoteNumber: 75, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 72, folderName: folderName, fileEnding: "_ms1_072_c4.wv", minimumNoteNumber: 70, maximumNoteNumber: 75, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 72, folderName: folderName, fileEnding: "_ms0_072_c4.wv", minimumNoteNumber: 70, maximumNoteNumber: 75, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 78, folderName: folderName, fileEnding: "_ms2_078_f#4.wv", minimumNoteNumber: 76, maximumNoteNumber: 81, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 78, folderName: folderName, fileEnding: "_ms1_078_f#4.wv", minimumNoteNumber: 76, maximumNoteNumber: 81, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 78, folderName: folderName, fileEnding: "_ms0_078_f#4.wv", minimumNoteNumber: 76, maximumNoteNumber: 81, minimumVelocity: 87, maximumVelocity: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 84, folderName: folderName, fileEnding: "_ms2_084_c5.wv", minimumNoteNumber: 82, maximumNoteNumber: 127, minimumVelocity: 0, maximumVelocity: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 84, folderName: folderName, fileEnding: "_ms1_084_c5.wv", minimumNoteNumber: 82, maximumNoteNumber: 127, minimumVelocity: 44, maximumVelocity: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 84, folderName: folderName, fileEnding: "_ms0_084_c5.wv", minimumNoteNumber: 82, maximumNoteNumber: 127, minimumVelocity: 87, maximumVelocity: 127)

        sampler.buildKeyMap()

        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")
    }
}
