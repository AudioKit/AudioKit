// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Super-naive code to read a .sfz file, as produced by vonRed's free ESX24-to-SFZ program
/// See https://bitbucket.org/vonred/exstosfz/downloads/ (you'll need Python 3 to run it).

extension Sampler {

    /// Load an SFZ at the given location
    ///
    /// Parameters:
    ///   - path: Path to the file as a string
    ///   - fileName: Name of the SFZ file
    ///
    internal func loadSFZ(path: String, fileName: String) {
        loadSFZ(url: URL(fileURLWithPath: path).appendingPathComponent(fileName))
    }

    /// Load an SFZ at the given location
    ///
    /// Parameters:
    ///   - url: File url to the SFZ file
    ///
    public func loadSFZ(url: URL) {

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

        let samplesBaseURL = url.deletingLastPathComponent()

        do {
            let data = try String(contentsOf: url, encoding: .ascii)
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
                            noteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1]) ?? 0
                            lowNoteNumber = noteNumber
                            highNoteNumber = noteNumber
                        } else if part.hasPrefix("lokey") {
                            lowNoteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1]) ?? 0
                        } else if part.hasPrefix("hikey") {
                            highNoteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1]) ?? 0
                        } else if part.hasPrefix("pitch_keycenter") {
                            noteNumber = MIDINoteNumber(part.components(separatedBy: "=")[1]) ?? 0
                        }
                    }
                }
                if trimmed.hasPrefix("<region>") {
                    // parse a <region> line
                    for part in trimmed.dropFirst(8).components(separatedBy: .whitespaces) {
                        if part.hasPrefix("lovel") {
                            lowVelocity = MIDIVelocity(part.components(separatedBy: "=")[1]) ?? 0
                        } else if part.hasPrefix("hivel") {
                            highVelocity = MIDIVelocity(part.components(separatedBy: "=")[1]) ?? 0
                        } else if part.hasPrefix("loop_mode") {
                            loopMode = part.components(separatedBy: "=")[1]
                        } else if part.hasPrefix("loop_start") {
                            loopStartPoint = Float32(part.components(separatedBy: "=")[1]) ?? 0
                        } else if part.hasPrefix("loop_end") {
                            loopEndPoint = Float32(part.components(separatedBy: "=")[1]) ?? 0
                        } else if part.hasPrefix("sample") {
                            sample = trimmed.components(separatedBy: "sample=")[1]
                        }
                    }

                    let noteFrequency = Float(440.0 * pow(2.0, (Double(noteNumber) - 69.0) / 12.0))

                    let noteLog = "load \(noteNumber) \(noteFrequency) NN range \(lowNoteNumber)-\(highNoteNumber)"
                    Log("\(noteLog) vel \(lowVelocity)-\(highVelocity) \(sample)")

                    let sampleDescriptor = SampleDescriptor(noteNumber: Int32(noteNumber),
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
                    sample = sample.replacingOccurrences(of: "\\", with: "/")
                    let sampleFileURL = samplesBaseURL
                        .appendingPathComponent(sample)
                    if sample.hasSuffix(".wv") {
                        sampleFileURL.path.withCString { path in
                            loadCompressedSampleFile(from: SampleFileDescriptor(sampleDescriptor: sampleDescriptor,
                                                                                  path: path))
                        }
                    } else {
                        if sample.hasSuffix(".aif") || sample.hasSuffix(".wav") {
                            let compressedFileURL = samplesBaseURL
                                .appendingPathComponent(String(sample.dropLast(4) + ".wv"))
                            let fileMgr = FileManager.default
                            if fileMgr.fileExists(atPath: compressedFileURL.path) {
                                compressedFileURL.path.withCString { path in
                                    loadCompressedSampleFile(
                                        from: SampleFileDescriptor(sampleDescriptor: sampleDescriptor,
                                                                     path: path))
                                }
                            } else {
                                let sampleFile = try AVAudioFile(forReading: sampleFileURL)
                                loadAudioFile(from: sampleDescriptor, file: sampleFile)
                            }
                        }
                    }
                }
            }
        } catch {
            Log("Could not load SFZ: \(error.localizedDescription)")
        }

        buildKeyMap()
        restartVoices()
    }
}
