//
//  AKAppleSampler+SoundFont.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

public extension AKAppleSampler {
    fileprivate func loadSoundFont(_ file: String, preset: Int, type: Int) throws {
        guard let url = findFileURL(file, withExtension: "sf2") else {
            AKLog("Soundfont file not found: \(file)")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        do {
            try samplerUnit.loadSoundBankInstrument(
                at: url,
                program: MIDIByte(preset),
                bankMSB: MIDIByte(type),
                bankLSB: MIDIByte(kAUSampler_DefaultBankLSB))
        } catch let error as NSError {
            AKLog("Error loading SoundFont \(file)")
            throw error
        }
    }

    /// Load a Bank from a SoundFont SF2 sample data file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 file without the .sf2 extension
    ///   - preset: Number of the program to use
    ///   - bank: Number of the bank to use
    ///
    @objc public func loadSoundFont(_ file: String, preset: Int, bank: Int) throws {
        guard let url = findFileURL(file, withExtension: "sf2") else {
            AKLog("Soundfont file not found: \(file)")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        do {
            var bMSB: Int
            if bank <= 127 {
                bMSB = kAUSampler_DefaultMelodicBankMSB
            } else {
                bMSB = kAUSampler_DefaultPercussionBankMSB
            }
            let bLSB: Int = bank % 128
            try samplerUnit.loadSoundBankInstrument(
                at: url,
                program: MIDIByte(preset),
                bankMSB: MIDIByte(bMSB),
                bankLSB: MIDIByte(bLSB))
        } catch let error as NSError {
            AKLog("Error loading SoundFont \(file)")
            throw error
        }
    }

    /// Load a Melodic SoundFont SF2 sample data file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 file without the .sf2 extension
    ///   - preset: Number of the program to use
    ///
    @objc public func loadMelodicSoundFont(_ file: String, preset: Int) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultMelodicBankMSB)
    }

    /// Load a Percussive SoundFont SF2 sample data file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 file without the .sf2 extension
    ///   - preset: Number of the program to use
    ///
    @objc public func loadPercussiveSoundFont(_ file: String, preset: Int = 0) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultPercussionBankMSB)
    }

}
