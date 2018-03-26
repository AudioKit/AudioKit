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
        // http://getdunne.net/download/ROMPlayer_Instruments.zip
        sampler.loadUsingSfzFile(folderPath: "/Users/shane/Downloads/ROMPlayer Instruments", sfzFileName: "TX Brass.sfz")

        // Illustration of how to load single-sample waveforms
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

        let sfzFiles = [ "TX Brass.sfz", "TX LoTine81z.sfz", "TX Metalimba.sfz", "TX Pluck Bass.sfz" ]
        sampler.unloadAllSamples()
        sampler.loadUsingSfzFile(folderPath: "/Users/shane/Downloads/ROMPlayer Instruments", sfzFileName: sfzFiles[byIndex])

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
    private func loadCompressed(baseURL: URL, noteNumber: MIDINoteNumber, folderName: String, fileEnding: String,
                                min_note: Int32 = -1, max_note: Int32 = -1, min_vel: Int32 = -1, max_vel: Int32 = -1) {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        let sd = AKSampleDescriptor(noteNumber: Int32(noteNumber),
                                    noteHz: Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)),
                                    min_note: min_note, max_note: max_note, min_vel: min_vel, max_vel: max_vel,
                                    // test looping based on fractional start/end values
            bLoop: true, fLoopStart: 0.2, fLoopEnd: 0.3, fStart: 0.0, fEnd: 0.0)
        sampler.loadCompressedSampleFile(sfd: AKSampleFileDescriptor(sd: sd, path: fileURL.path))
    }

    func loadAndMapCompressedSampleFiles() {
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime

        // Download http://getdunne.com/download/TX_LoTine81z.zip
        // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
        // Uncompress and put folder inside wherever baseURL (see above) points

        let baseURL = URL(fileURLWithPath: "/Users/shane/Desktop/Compressed Sounds")
        let folderName = "TX LoTine81z"

        loadCompressed(baseURL: baseURL, noteNumber: 48, folderName: folderName, fileEnding: "_ms2_048_c2.wv", min_note: 0, max_note: 51, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 48, folderName: folderName, fileEnding: "_ms1_048_c2.wv", min_note: 0, max_note: 51, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 48, folderName: folderName, fileEnding: "_ms0_048_c2.wv", min_note: 0, max_note: 51, min_vel: 87, max_vel: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 54, folderName: folderName, fileEnding: "_ms2_054_f#2.wv", min_note: 52, max_note: 57, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 54, folderName: folderName, fileEnding: "_ms1_054_f#2.wv", min_note: 52, max_note: 57, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 54, folderName: folderName, fileEnding: "_ms0_054_f#2.wv", min_note: 52, max_note: 57, min_vel: 87, max_vel: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 60, folderName: folderName, fileEnding: "_ms2_060_c3.wv", min_note: 58, max_note: 63, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 60, folderName: folderName, fileEnding: "_ms1_060_c3.wv", min_note: 58, max_note: 63, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 60, folderName: folderName, fileEnding: "_ms0_060_c3.wv", min_note: 58, max_note: 63, min_vel: 87, max_vel: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 66, folderName: folderName, fileEnding: "_ms2_066_f#3.wv", min_note: 64, max_note: 69, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 66, folderName: folderName, fileEnding: "_ms1_066_f#3.wv", min_note: 64, max_note: 69, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 66, folderName: folderName, fileEnding: "_ms0_066_f#3.wv", min_note: 64, max_note: 69, min_vel: 87, max_vel: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 72, folderName: folderName, fileEnding: "_ms2_072_c4.wv", min_note: 70, max_note: 75, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 72, folderName: folderName, fileEnding: "_ms1_072_c4.wv", min_note: 70, max_note: 75, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 72, folderName: folderName, fileEnding: "_ms0_072_c4.wv", min_note: 70, max_note: 75, min_vel: 87, max_vel: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 78, folderName: folderName, fileEnding: "_ms2_078_f#4.wv", min_note: 76, max_note: 81, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 78, folderName: folderName, fileEnding: "_ms1_078_f#4.wv", min_note: 76, max_note: 81, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 78, folderName: folderName, fileEnding: "_ms0_078_f#4.wv", min_note: 76, max_note: 81, min_vel: 87, max_vel: 127)

        loadCompressed(baseURL: baseURL, noteNumber: 84, folderName: folderName, fileEnding: "_ms2_084_c5.wv", min_note: 82, max_note: 127, min_vel: 0, max_vel: 43)
        loadCompressed(baseURL: baseURL, noteNumber: 84, folderName: folderName, fileEnding: "_ms1_084_c5.wv", min_note: 82, max_note: 127, min_vel: 44, max_vel: 86)
        loadCompressed(baseURL: baseURL, noteNumber: 84, folderName: folderName, fileEnding: "_ms0_084_c5.wv", min_note: 82, max_note: 127, min_vel: 87, max_vel: 127)

        sampler.buildKeyMap()

        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")
    }
}
