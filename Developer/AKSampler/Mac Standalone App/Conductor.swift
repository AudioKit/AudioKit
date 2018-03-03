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
    var sustainer: AKSustainer

    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2

    var synthSemitoneOffset = 0
    
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
        sustainer = AKSustainer(sampler)
        
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
        // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
        // Uncompress and put folder inside wherever baseURL (see above) points
        let folderName = "TX LoTine81z"
        
        loadCompressed(48, folderName, "_ms2_048_c2.wv", 0, 51, 0, 43)
        loadCompressed(48, folderName, "_ms1_048_c2.wv", 0, 51, 44, 86)
        loadCompressed(48, folderName, "_ms0_048_c2.wv", 0, 51, 87, 127)
        
        loadCompressed(54, folderName, "_ms2_054_f#2.wv", 52, 57, 0, 43)
        loadCompressed(54, folderName, "_ms1_054_f#2.wv", 52, 57, 44, 86)
        loadCompressed(54, folderName, "_ms0_054_f#2.wv", 52, 57, 87, 127)
        
        loadCompressed(60, folderName, "_ms2_060_c3.wv", 58, 63, 0, 43)
        loadCompressed(60, folderName, "_ms1_060_c3.wv", 58, 63, 44, 86)
        loadCompressed(60, folderName, "_ms0_060_c3.wv", 58, 63, 87, 127)
        
        loadCompressed(66, folderName, "_ms2_066_f#3.wv", 64, 69, 0, 43)
        loadCompressed(66, folderName, "_ms1_066_f#3.wv", 64, 69, 44, 86)
        loadCompressed(66, folderName, "_ms0_066_f#3.wv", 64, 69, 87, 127)
        
        loadCompressed(72, folderName, "_ms2_072_c4.wv", 70, 75, 0, 43)
        loadCompressed(72, folderName, "_ms1_072_c4.wv", 70, 75, 44, 86)
        loadCompressed(72, folderName, "_ms0_072_c4.wv", 70, 75, 87, 127)
        
        loadCompressed(78, folderName, "_ms2_078_f#4.wv", 76, 81, 0, 43)
        loadCompressed(78, folderName, "_ms1_078_f#4.wv", 76, 81, 44, 86)
        loadCompressed(78, folderName, "_ms0_078_f#4.wv", 76, 81, 87, 127)
        
        loadCompressed(84, folderName, "_ms2_084_c5.wv", 82, 127, 0, 43)
        loadCompressed(84, folderName, "_ms1_084_c5.wv", 82, 127, 44, 86)
        loadCompressed(84, folderName, "_ms0_084_c5.wv", 82, 127, 87, 127)
        
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
