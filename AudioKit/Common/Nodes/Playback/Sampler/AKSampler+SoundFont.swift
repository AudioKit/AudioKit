//
//  AKSampler+SoundFont.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 2/28/17.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKSampler {
    fileprivate func loadSoundFont(_ file: String, preset: Int, type: Int) throws {
        guard let url = Bundle.main.url(forResource: file, withExtension: "sf2") else {
            fatalError("file not found.")
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
    open func loadSoundFont(_ file: String, preset: Int, bank: Int) throws {
        guard let url = Bundle.main.url(forResource: file, withExtension: "sf2") else {
            fatalError("file not found.")
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
    open func loadMelodicSoundFont(_ file: String, preset: Int) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultMelodicBankMSB)
    }

    /// Load a Percussive SoundFont SF2 sample data file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 file without the .sf2 extension
    ///   - preset: Number of the program to use
    ///
    open func loadPercussiveSoundFont(_ file: String, preset: Int = 0) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultPercussionBankMSB)
    }

}
