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

        let folderName = "X50 Golden Strings"
        var noteNumber: MIDINoteNumber = 12
        loadCompressed(noteNumber, folderName, "-C0.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-C1.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-C2.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-C3.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-C4.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-C5.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-C6.wv"); noteNumber += 12
        noteNumber = 18
        loadCompressed(noteNumber, folderName, "-F#0.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-F#1.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-F#2.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-F#3.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-F#4.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-F#5.wv"); noteNumber += 12
        loadCompressed(noteNumber, folderName, "-F#6.wv")
        
        sampler.buildSimpleKeyMap()

        // MM single sample
//        sampler.ampAttackTime = 0.01
//        sampler.ampDecayTime = 0.1
//        sampler.ampSustainLevel = 0.8
//        sampler.ampReleaseTime = 0.5
//        sampler.filterAttackTime = 0.01
//        sampler.filterDecayTime = 0.0
//        sampler.filterSustainLevel = 1.0
//        sampler.filterReleaseTime = 10.0
        
        // Golden Strings etc.
        sampler.ampAttackTime = 0.3
        sampler.ampDecayTime = 0.1
        sampler.ampSustainLevel = 0.8
        sampler.ampReleaseTime = 0.5
//        sampler.filterEnable = true
//        sampler.filterAttackTime = 3.0
//        sampler.filterDecayTime = 3.0
//        sampler.filterSustainLevel = 0.2
//        sampler.filterReleaseTime = 10.0

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

    private func loadCompressed(noteNumber: MIDINoteNumber, wvurl: URL)
    {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: wvurl.path) {
            print("No such file \(wvurl.path)")
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
                                      data: sampleBuffer, channelCount: UInt32(numChannels), sampleCount: UInt32(numSamples))
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
    }
    
    private func loadCompressed(_ noteNumber: MIDINoteNumber, _ folderName: String, _ fileEnding: String)
    {
        let fileUtils = FileManagerUtils.shared
        
        let folderURL = fileUtils.getDocsUrl(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        loadCompressed(noteNumber: noteNumber, wvurl: fileURL)
    }

    private func loadSample(_ noteNumber: MIDINoteNumber, _ fullPath: String)
    {
        let fileManager = FileManager.default
        let fileUtils = FileManagerUtils.shared
        do {
            let fileURL = fileUtils.getDocsUrl(fullPath)
            if fileManager.fileExists(atPath: fileURL.path) {
                let sampleFile = try AKAudioFile(forReading: fileURL)
                let noteHz = Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
                sampler.loadAKAudioFile(noteNumber: noteNumber, noteHz: noteHz, file: sampleFile)//, bLoop: false)
            }
            else {
                print("No such file \(fullPath)")
            }
        } catch let error as NSError {
            print("\(error.localizedDescription) loading audio file \(fullPath)")
        }
    }
    
    private func loadSample(_ noteNumber: MIDINoteNumber, _ folderName: String, _ fileEnding: String)
    {
        let fileManager = FileManager.default
        let fileUtils = FileManagerUtils.shared
        let folderURL = fileUtils.getDocsUrl(folderName)
        let fileName = folderName + fileEnding
        do {
            let fileURL = folderURL.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: fileURL.path) {
                let sampleFile = try AKAudioFile(forReading: fileURL)
                let noteHz = Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
                sampler.loadAKAudioFile(noteNumber: noteNumber, noteHz: noteHz, file: sampleFile)//, bLoop: false)
            }
            else {
                print("No such file \(fileName)")
            }
        } catch let error as NSError {
            print("\(error.localizedDescription) loading audio file \(fileName)")
        }
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
        // key-up, key-down and pedal operations are mediated by SDSustainer
        sustainer.play(noteNumber: offsetNote(note, semitones: synthSemitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        // key-up, key-down and pedal operations are mediated by SDSustainer
        sustainer.stop(noteNumber: offsetNote(note, semitones: synthSemitoneOffset))
    }

    func allNotesOff() {
        for note in 0 ... 127 {
            sustainer.stop(noteNumber: MIDINoteNumber(note))
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
            sampler.pitchBend = scale * self.pitchBendUpSemitones
        } else {
            sampler.pitchBend = scale * self.pitchBendDownSemitones
        }
    }

}
