//
//  AKSampler+SFZ.swift
//  AKSampler
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKSampler {
    // Super-naive code to read a .sfz file, as produced by vonRed's free ESX24-to-SFZ program
    // See https://bitbucket.org/vonred/exstosfz/downloads/ (you'll need Python 3 to run it).

    open func loadUsingSfzFile(folderPath: String, sfzFileName: String) {

        stopAllVoices()
        unloadAllSamples()

        var lokey: Int32 = 0
        var hikey: Int32 = 127
        var pitch: Int32 = 60
        var lovel: Int32 = 0
        var hivel: Int32 = 127
        var sample: String = ""
        var loopmode: String = ""
        var loopstart: Float32 = 0
        var loopend: Float32 = 0

        let baseURL = URL(fileURLWithPath: folderPath)
        let sfzURL = baseURL.appendingPathComponent(sfzFileName)
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
                    lokey = 0
                    hikey = 127
                    pitch = 60
                    for part in trimmed.dropFirst(7).components(separatedBy: .whitespaces) {
                        if part.hasPrefix("key") {
                            pitch = Int32(part.components(separatedBy: "=")[1])!
                            lokey = pitch
                            hikey = pitch
                        } else if part.hasPrefix("lokey") {
                            lokey = Int32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("hikey") {
                            hikey = Int32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("pitch_keycenter") {
                            pitch = Int32(part.components(separatedBy: "=")[1])!
                        }
                    }
                }
                if trimmed.hasPrefix("<region>") {
                    // parse a <region> line
                    lovel = 0
                    hivel = 127
                    sample = ""
                    loopmode = ""
                    loopstart = 0
                    loopend = 0
                    for part in trimmed.dropFirst(8).components(separatedBy: .whitespaces) {
                        if part.hasPrefix("lovel") {
                            lovel = Int32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("hivel") {
                            hivel = Int32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("loop_mode") {
                            loopmode = part.components(separatedBy: "=")[1]
                        } else if part.hasPrefix("loop_start") {
                            loopstart = Float32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("loop_end") {
                            loopend = Float32(part.components(separatedBy: "=")[1])!
                        } else if part.hasPrefix("sample") {
                            sample = trimmed.components(separatedBy: "sample=")[1]
                        }
                    }

                    let noteFreq = Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(pitch)))
                    print("load \(pitch) \(noteFreq) Hz range \(lokey)-\(hikey) vel \(lovel)-\(hivel) \(sample)")

                    let sd = AKSampleDescriptor(noteNumber: pitch,
                                                noteHz: noteFreq,
                                                min_note: lokey,
                                                max_note: hikey,
                                                min_vel: lovel,
                                                max_vel: hivel,
                                                bLoop: loopmode != "",
                                                fLoopStart: loopstart,
                                                fLoopEnd: loopend,
                                                fStart: 0.0,
                                                fEnd: 0.0)
                    let sampleFileURL = baseURL.appendingPathComponent(sample)
                    if sample.hasSuffix(".wv") {
                        loadCompressedSampleFile(sfd: AKSampleFileDescriptor(sd: sd, path: sampleFileURL.path))
                    } else {
                        if sample.hasSuffix(".aif") || sample.hasSuffix(".wav") {
                            let compressedFileURL = baseURL.appendingPathComponent(String(sample.dropLast(4) + ".wv"))
                            let fileMgr = FileManager.default
                            if fileMgr.fileExists(atPath: compressedFileURL.path) {
                                loadCompressedSampleFile(sfd: AKSampleFileDescriptor(sd: sd, path: compressedFileURL.path))
                            } else {
                                let sampleFile = try AKAudioFile(forReading: sampleFileURL)
                                loadAKAudioFile(sd: sd, file: sampleFile)
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
        }

        buildKeyMap()
        restartVoices()
    }
}
