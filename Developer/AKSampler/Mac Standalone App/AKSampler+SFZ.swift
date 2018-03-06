//
//  AKSampler+SFZ.swift
//  AKSampler
//
//  Created by Shane Dunne on 2018-03-05.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

import AudioKit

extension AKSampler
{
    private func loadCompressed(baseURL: URL, noteNumber: MIDINoteNumber, folderName: String, fileEnding: String,
                                min_note: Int32 = -1, max_note: Int32 = -1, min_vel: Int32 = -1, max_vel: Int32 = -1)
    {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        let sd = AKSampleDescriptor(noteNumber: Int32(noteNumber), noteHz: Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)), min_note: min_note, max_note: max_note, min_vel: min_vel, max_vel: max_vel, bLoop: true, fLoopStart: 0.0, fLoopEnd: 0.0, fStart: 0.0, fEnd: 0.0)
        loadCompressedSampleFile(sfd: AKSampleFileDescriptor(sd: sd, path: fileURL.path))
    }

    func loadCrap()
    {
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
        
        buildKeyMap()
        
        let elapsedTime = info.systemUptime - begin
        print("Time to load samples \(elapsedTime) seconds")
    }
    
    // Super-naive code to read a .sfz file, as produced by vonRed's free ESX24-to-SFZ program
    // See https://bitbucket.org/vonred/exstosfz/downloads/ and note you'll need Python 3
    func loadSFZ()
    {
        // set these according to your own data
        let folderPath = "/Users/shane/Documents/GitHub/ROMPlayer/RomPlayer/Sounds/Sampler Instruments"
        let sfzFileName = "LoTineComp.sfz"
        
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime

        var lokey: Int32 = 0
        var hikey: Int32 = 127
        var pitch: Int32 = 60
        var lovel: Int32 = 0
        var hivel: Int32 = 127
        var sample: String = ""
        
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
                    let start = trimmed.index(trimmed.startIndex, offsetBy: 7)
                    let parts = trimmed[start...].components(separatedBy: .whitespaces)
                    for part in parts {
                        if part.hasPrefix("lokey") {
                            lokey = Int32(part.components(separatedBy: "=")[1])!
                        }
                        else if part.hasPrefix("hikey") {
                            hikey = Int32(part.components(separatedBy: "=")[1])!
                        }
                        else if part.hasPrefix("pitch_keycenter") {
                            pitch = Int32(part.components(separatedBy: "=")[1])!
                        }
                    }
                }
                if trimmed.hasPrefix("<region>") {
                    // parse a <region> line
                    let start = trimmed.index(trimmed.startIndex, offsetBy: 8)
                    let parts = trimmed[start...].components(separatedBy: .whitespaces)
                    for part in parts {
                        if part.hasPrefix("lovel") {
                            lovel = Int32(part.components(separatedBy: "=")[1])!
                        }
                        else if part.hasPrefix("hivel") {
                            hivel = Int32(part.components(separatedBy: "=")[1])!
                        }
                        else if part.hasPrefix("sample") {
                            sample = trimmed.components(separatedBy: "sample=")[1]
                        }
                    }
                    
                    let noteFreq = Float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(pitch)))
                    print("load \(pitch) \(noteFreq) Hz range \(lokey)-\(hikey) vel \(lovel)-\(hivel) \(sample)")
                    
                    let sd = AKSampleDescriptor(noteNumber: pitch, noteHz: noteFreq, min_note: lokey, max_note: hikey, min_vel: lovel, max_vel: hivel, bLoop: true, fLoopStart: 0.0, fLoopEnd: 0.0, fStart: 0.0, fEnd: 0.0)
                    let sampleFileURL = baseURL.appendingPathComponent(sample)
                    if sample.hasSuffix(".wv")
                    {
                        loadCompressedSampleFile(sfd: AKSampleFileDescriptor(sd: sd, path: sampleFileURL.path))
                    } else {
                        let sampleFile = try AKAudioFile(forReading: sampleFileURL)
                        loadAKAudioFile(sd: sd, file: sampleFile)
                    }
                }
            }
        } catch {
            print(error)
        }
        
        buildKeyMap()
        
        let elapsedTime = info.systemUptime - begin
        print("loatSFZ: Time to load samples \(elapsedTime) seconds")
    }
}
