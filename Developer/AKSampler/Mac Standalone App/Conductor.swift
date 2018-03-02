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
    var sampler: AKSampler2
    var sustainer: AKSustainer

    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2

    var synthSemitoneOffset = -12
    
    //let baseURL = URL(fileURLWithPath: "/Users/shane/Desktop/OLD Sounds/Sampler Instruments")
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
        sampler = AKSampler2()
        sustainer = AKSustainer(sampler)
        
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        
        let folder = "/Users/shane/Documents/GitHub/SuperFM/FMPlayer/Sounds/Sampler Instruments/samples/"
        loadSample(36, folder + "E Piano 7_ms6_036_c1.aif", 0, 39, 0, 39)
        loadSample(36, folder + "E Piano 7_ms5_036_c1.aif", 0, 39, 40, 71)
        loadSample(36, folder + "E Piano 7_ms4_036_c1.aif", 0, 39, 72, 89)
        loadSample(36, folder + "E Piano 7_ms3_036_c1.aif", 0, 39, 90, 103)
        loadSample(36, folder + "E Piano 7_ms2_036_c1.aif", 0, 39, 104, 110)
        loadSample(36, folder + "E Piano 7_ms1_036_c1.aif", 0, 39, 111, 119)
        loadSample(36, folder + "E Piano 7_ms0_036_c1.aif", 0, 39, 120, 127)

        loadSample(42, folder + "E Piano 7_ms6_042_f#1.aif", 40, 45, 0, 39)
        loadSample(42, folder + "E Piano 7_ms5_042_f#1.aif", 40, 45, 40, 71)
        loadSample(42, folder + "E Piano 7_ms4_042_f#1.aif", 40, 45, 72, 89)
        loadSample(42, folder + "E Piano 7_ms3_042_f#1.aif", 40, 45, 90, 103)
        loadSample(42, folder + "E Piano 7_ms2_042_f#1.aif", 40, 45, 104, 110)
        loadSample(42, folder + "E Piano 7_ms1_042_f#1.aif", 40, 45, 111, 119)
        loadSample(42, folder + "E Piano 7_ms0_042_f#1.aif", 40, 45, 120, 127)

        loadSample(48, folder + "E Piano 7_ms6_048_c2.aif", 46, 51, 0, 39)
        loadSample(48, folder + "E Piano 7_ms5_048_c2.aif", 46, 51, 40, 71)
        loadSample(48, folder + "E Piano 7_ms4_048_c2.aif", 46, 51, 72, 89)
        loadSample(48, folder + "E Piano 7_ms3_048_c2.aif", 46, 51, 90, 103)
        loadSample(48, folder + "E Piano 7_ms2_048_c2.aif", 46, 51, 104, 110)
        loadSample(48, folder + "E Piano 7_ms1_048_c2.aif", 46, 51, 111, 119)
        loadSample(48, folder + "E Piano 7_ms0_048_c2.aif", 46, 51, 120, 127)

        loadSample(54, folder + "E Piano 7_ms6_054_f#2.aif", 52, 57, 0, 39)
        loadSample(54, folder + "E Piano 7_ms5_054_f#2.aif", 52, 57, 40, 71)
        loadSample(54, folder + "E Piano 7_ms4_054_f#2.aif", 52, 57, 72, 89)
        loadSample(54, folder + "E Piano 7_ms3_054_f#2.aif", 52, 57, 90, 103)
        loadSample(54, folder + "E Piano 7_ms2_054_f#2.aif", 52, 57, 104, 110)
        loadSample(54, folder + "E Piano 7_ms1_054_f#2.aif", 52, 57, 111, 119)
        loadSample(54, folder + "E Piano 7_ms0_054_f#2.aif", 52, 57, 120, 127)

        loadSample(60, folder + "E Piano 7_ms6_060_c3.aif", 58, 63, 0, 39)
        loadSample(60, folder + "E Piano 7_ms5_060_c3.aif", 58, 63, 40, 71)
        loadSample(60, folder + "E Piano 7_ms4_060_c3.aif", 58, 63, 72, 89)
        loadSample(60, folder + "E Piano 7_ms3_060_c3.aif", 58, 63, 90, 103)
        loadSample(60, folder + "E Piano 7_ms2_060_c3.aif", 58, 63, 104, 110)
        loadSample(60, folder + "E Piano 7_ms1_060_c3.aif", 58, 63, 111, 119)
        loadSample(60, folder + "E Piano 7_ms0_060_c3.aif", 58, 63, 120, 127)

        loadSample(66, folder + "E Piano 7_ms6_066_f#3.aif", 64, 69, 0, 39)
        loadSample(66, folder + "E Piano 7_ms5_066_f#3.aif", 64, 69, 40, 71)
        loadSample(66, folder + "E Piano 7_ms4_066_f#3.aif", 64, 69, 72, 89)
        loadSample(66, folder + "E Piano 7_ms3_066_f#3.aif", 64, 69, 90, 103)
        loadSample(66, folder + "E Piano 7_ms2_066_f#3.aif", 64, 69, 104, 110)
        loadSample(66, folder + "E Piano 7_ms1_066_f#3.aif", 64, 69, 111, 119)
        loadSample(66, folder + "E Piano 7_ms0_066_f#3.aif", 64, 69, 120, 127)

        loadSample(72, folder + "E Piano 7_ms6_072_c4.aif", 70, 75, 0, 39)
        loadSample(72, folder + "E Piano 7_ms5_072_c4.aif", 70, 75, 40, 71)
        loadSample(72, folder + "E Piano 7_ms4_072_c4.aif", 70, 75, 72, 89)
        loadSample(72, folder + "E Piano 7_ms3_072_c4.aif", 70, 75, 90, 103)
        loadSample(72, folder + "E Piano 7_ms2_072_c4.aif", 70, 75, 104, 110)
        loadSample(72, folder + "E Piano 7_ms1_072_c4.aif", 70, 75, 111, 119)
        loadSample(72, folder + "E Piano 7_ms0_072_c4.aif", 70, 75, 120, 127)

        loadSample(78, folder + "E Piano 7_ms6_078_f#4.aif", 76, 81, 0, 39)
        loadSample(78, folder + "E Piano 7_ms5_078_f#4.aif", 76, 81, 40, 71)
        loadSample(78, folder + "E Piano 7_ms4_078_f#4.aif", 76, 81, 72, 89)
        loadSample(78, folder + "E Piano 7_ms3_078_f#4.aif", 76, 81, 90, 103)
        loadSample(78, folder + "E Piano 7_ms2_078_f#4.aif", 76, 81, 104, 110)
        loadSample(78, folder + "E Piano 7_ms1_078_f#4.aif", 76, 81, 111, 119)
        loadSample(78, folder + "E Piano 7_ms0_078_f#4.aif", 76, 81, 120, 127)

        loadSample(84, folder + "E Piano 7_ms6_084_c5.aif", 82, 127, 0, 39)
        loadSample(84, folder + "E Piano 7_ms5_084_c5.aif", 82, 127, 40, 71)
        loadSample(84, folder + "E Piano 7_ms4_084_c5.aif", 82, 127, 72, 89)
        loadSample(84, folder + "E Piano 7_ms3_084_c5.aif", 82, 127, 90, 103)
        loadSample(84, folder + "E Piano 7_ms2_084_c5.aif", 82, 127, 104, 110)
        loadSample(84, folder + "E Piano 7_ms1_084_c5.aif", 82, 127, 111, 119)
        loadSample(84, folder + "E Piano 7_ms0_084_c5.aif", 82, 127, 120, 127)
        
        sampler.buildKeyMap()

        sampler.ampReleaseTime = 0.4
        
        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")
        
        // Set Output & Start AudioKit
        AudioKit.output = sampler
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }
    }
    
    private func loadCompressed(noteNumber: MIDINoteNumber, wvPath: String,
                                _ min_note: Int32 = -1, _ max_note: Int32 = -1, _ min_vel: Int32 = -1, _ max_vel: Int32 = -1)
    {
        let wvurl = URL(fileURLWithPath: wvPath);
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: wvurl.path) {
            print("No such file \(wvPath)")
            return;
        }
        
        var numChannels: Int32 = 0
        var numSamples: Int32 = 0
        do {
            let wv = try FileHandle(forReadingFrom: wvurl)
            let status = getWvData(wv.fileDescriptor, &numChannels, &numSamples)
            if status != 0 {
                print("getWvData returns \(status)")
                return
            }
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        
        do {
            let sampleBuffer = UnsafeMutablePointer<Float32>.allocate(capacity: Int(numChannels * numSamples))
            let wv = try FileHandle(forReadingFrom: wvurl)
            let status = getWvSamples(wv.fileDescriptor, sampleBuffer)
            if status != 0 {
                print("getWvSamples returns \(status)")
                return
            }
            sampler.loadRawSampleData(noteNumber: noteNumber,
                                      noteHz: Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)),
                                      data: sampleBuffer, channelCount: UInt32(numChannels), sampleCount: UInt32(numSamples),
                                      bInterleaved: true, min_note: min_note, max_note: max_note, min_vel: min_vel, max_vel: max_vel)
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
    }
    
    private func loadCompressed(_ noteNumber: MIDINoteNumber, _ folderName: String, _ fileEnding: String,
                                _ min_note: Int32 = -1, _ max_note: Int32 = -1, _ min_vel: Int32 = -1, _ max_vel: Int32 = -1)
    {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        loadCompressed(noteNumber: noteNumber, wvPath: fileURL.path, min_note, max_note, min_vel, max_vel)
    }

    private func loadCompressed(_ noteNumber: MIDINoteNumber, _ fileName: String,
                                _ min_note: Int32 = -1, _ max_note: Int32 = -1, _ min_vel: Int32 = -1, _ max_vel: Int32 = -1)
    {
        let fileURL = baseURL.appendingPathComponent(fileName)
        loadCompressed(noteNumber: noteNumber, wvPath: fileURL.path, min_note, max_note, min_vel, max_vel)
    }
    
    private func loadSample(_ noteNumber: MIDINoteNumber, _ fullPath: String,
                            _ min_note: Int32 = -1, _ max_note: Int32 = -1, _ min_vel: Int32 = -1, _ max_vel: Int32 = -1)
    {
        let fileManager = FileManager.default
        do {
            let fileURL = URL(fileURLWithPath: fullPath)
            if fileManager.fileExists(atPath: fileURL.path) {
                let sampleFile = try AKAudioFile(forReading: fileURL)
                let noteHz = Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
                sampler.loadAKAudioFile(noteNumber: noteNumber, noteHz: noteHz, file: sampleFile,
                                        min_note: min_note, max_note: max_note,
                                        min_vel: min_vel, max_vel: max_vel)
            }
            else {
                print("No such file \(fullPath)")
            }
        } catch let error as NSError {
            print("\(error.localizedDescription) loading audio file \(fullPath)")
        }
    }
    
    private func loadSample(_ noteNumber: MIDINoteNumber, _ folderName: String, _ fileEnding: String,
                            _ min_note: Int32 = -1, _ max_note: Int32 = -1, _ min_vel: Int32 = -1, _ max_vel: Int32 = -1)
    {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        loadSample(noteNumber, fileURL.path, min_note, max_note, min_vel, max_vel)
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
        // key-up, key-down and pedal operations are mediated by AKSustainer
        sustainer.play(noteNumber: offsetNote(note, semitones: synthSemitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        // key-up, key-down and pedal operations are mediated by AKSustainer
        sustainer.stop(noteNumber: offsetNote(note, semitones: synthSemitoneOffset))
    }

    func allNotesOff() {
        for note in 0 ... 127 {
            sampler.silence(noteNumber: MIDINoteNumber(note))
            sustainer.stop(noteNumber: MIDINoteNumber(note))
        }
    }

    func afterTouch(_ pressure: MIDIByte) {
    }

    func controller(_ controller: MIDIByte, value: MIDIByte) {
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            sampler.vibratoDepth = 0.5 * Double(value) / 128.0
        case AKMIDIControl.damperOnOff.rawValue:
            // key-up, key-down and pedal operations are mediated by AKSustainer
            sustainer.sustain(down: value != 0)
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
