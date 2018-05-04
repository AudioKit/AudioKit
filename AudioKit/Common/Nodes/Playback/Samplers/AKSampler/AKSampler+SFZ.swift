//
//  AKSampler+SFZ.swift
//  AKSampler
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Super-naive code to read a .sfz file, as produced by vonRed's free ESX24-to-SFZ program
/// See https://bitbucket.org/vonred/exstosfz/downloads/ (you'll need Python 3 to run it).

extension AKSampler {

    /// Load an SFZ at the given location
    ///
    /// Parameters:
    ///   - path: Path tothe file as a string
    ///   - fileName: Name of the SFZ file
    ///
    open func loadSFZ(path: String, fileName: String) {

        stopAllVoices()
        unloadAllSamples()

        var lowNoteNumber: MIDINoteNumber = 0
        var highNoteNumber: MIDINoteNumber = 127
        var noteNumber: MIDINoteNumber = 60
        var lowVelocity: MIDIVelocity = 0
        var highVelocity: MIDIVelocity = 127
        var sample: String = ""
        var loopMode: String = ""
        var loopStartPoint: Float32 = 0
        var loopEndPoint: Float32 = 0

        let baseURL = URL(fileURLWithPath: path)
        let sfzURL = baseURL.appendingPathComponent(fileName)
        do {
            let data = try String(contentsOf: sfzURL, encoding: .ascii)
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = String(line.trimmingCharacters(in: .whitespacesAndNewlines))
                if trimmed == "" || trimmed.hasPrefix("//") {
                    // ignore blank lines and comment lines
                    continue
                }
                if trimmed.hasPrefix("<group>") {
                    // parse a <group> line
                    for part in trimmed.dropFirst(7).components(separatedBy: .whitespaces) {
                        if part.hasPrefix("key") {
                            noteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1])!
                            lowNoteNumber = noteNumber
                            highNoteNumber = noteNumber
                        } else if part.hasPrefix("lokey") {
                            lowNoteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("hikey") {
                            highNoteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("pitch_keycenter") {
                            noteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1])!
                        }
                    }
                }
                if trimmed.hasPrefix("<region>") {
                    // parse a <region> line
                    for part in trimmed.dropFirst(8).components(separatedBy: .whitespaces) {
                        if part.hasPrefix("lovel") {
                            lowVelocity = MIDIVelocity(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("hivel") {
                            highVelocity = MIDIVelocity(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("loop_mode") {
                            loopMode = part.components(separatedBy: "=")[1]
                        } else if part.hasPrefix("loop_start") {
                            loopStartPoint = Float32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("loop_end") {
                            loopEndPoint = Float32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("sample") {
                            sample = trimmed.components(separatedBy: "sample=")[1]
                        }
                    }

                    let noteFrequency = Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
                    let noteLog = "load \(noteNumber) \(noteFrequency) NN range \(lowNoteNumber)-\(highNoteNumber)"
                    AKLog("\(noteLog) vel \(lowVelocity)-\(highVelocity) \(sample)")

                    let sampleDescriptor = AKSampleDescriptor(noteNumber: Int32(noteNumber),
                                                              noteFrequency: noteFrequency,
                                                              minimumNoteNumber: Int32(lowNoteNumber),
                                                              maximumNoteNumber: Int32(highNoteNumber),
                                                              minimumVelocity: Int32(lowVelocity),
                                                              maximumVelocity: Int32(highVelocity),
                                                              isLooping: loopMode != "",
                                                              loopStartPoint: loopStartPoint,
                                                              loopEndPoint: loopEndPoint,
                                                              startPoint: 0.0,
                                                              endPoint: 0.0)
                    let sampleFileURL = baseURL.appendingPathComponent(sample)
                    if sample.hasSuffix(".wv") {
                        loadCompressedSampleFile(from: AKSampleFileDescriptor(sampleDescriptor: sampleDescriptor,
                                                                              path: sampleFileURL.path))
                    } else {
                        if sample.hasSuffix(".aif") || sample.hasSuffix(".wav") {
                            let compressedFileURL = baseURL.appendingPathComponent(String(sample.dropLast(4) + ".wv"))
                            let fileMgr = FileManager.default
                            if fileMgr.fileExists(atPath: compressedFileURL.path) {
                                loadCompressedSampleFile(
                                    from: AKSampleFileDescriptor(sampleDescriptor: sampleDescriptor,
                                                                 path: compressedFileURL.path))
                            } else {
                                let sampleFile = try AKAudioFile(forReading: sampleFileURL)
                                loadAKAudioFile(from: sampleDescriptor, file: sampleFile)
                            }
                        }
                    }
                }
            }
        } catch {
            AKLog(error)
        }

        buildKeyMap()
        restartVoices()
    }
}
