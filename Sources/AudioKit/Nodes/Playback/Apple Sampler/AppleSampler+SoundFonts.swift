import AVFoundation

// SoundFont Support
public extension AppleSampler {
    internal func loadSoundFont(_ file: String, preset: Int, type: Int, in bundle: Bundle = .main) throws {
        guard let url = findFileURL(file, withExtension: ["sf2", "dls"], in: bundle) else {
            Log("SoundFont file not found: \(file)")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        do {
            try samplerUnit.loadSoundBankInstrument(
                at: url,
                program: MIDIByte(preset),
                bankMSB: MIDIByte(type),
                bankLSB: MIDIByte(kAUSampler_DefaultBankLSB)
            )
        } catch let error as NSError {
            Log("Error loading SoundFont \(file)")
            throw error
        }
    }

    internal func loadSoundFont(url: URL, preset: Int, type: Int, in bundle: Bundle = .main) throws {
        do {
            try samplerUnit.loadSoundBankInstrument(
                at: url,
                program: MIDIByte(preset),
                bankMSB: MIDIByte(type),
                bankLSB: MIDIByte(kAUSampler_DefaultBankLSB)
            )
        } catch let error as NSError {
            Log("Error loading SoundFont \(url)")
            throw error
        }
    }

    /// Load a Bank from a SoundFont SF2 sample data file or a DLS file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 or the DLS file without the .sf2 / .dls extension
    ///   - preset: Number of the program to use
    ///   - bank: Number of the bank to use
    ///   - bundle: The bundle from which to load the file. Defaults to main bundle.
    ///
    func loadSoundFont(_ file: String, preset: Int, bank: Int, in bundle: Bundle = .main) throws {
        guard let url = findFileURL(file, withExtension: ["sf2", "dls"], in: bundle) else {
            Log("Soundfont file not found: \(file)")
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
                bankLSB: MIDIByte(bLSB)
            )
        } catch let error as NSError {
            Log("Error loading SoundFont \(file)")
            throw error
        }
    }

    /// Load a Melodic SoundFont SF2 sample data file or a DLS file
    /// - Parameters:
    ///   - url: Location of the file
    ///   - preset: Number of the program to use
    ///   - bundle: The bundle from which to load the file. Defaults to main bundle.
    func loadMelodicSoundFont(url: URL, preset: Int, in bundle: Bundle = .main) throws {
        try loadSoundFont(url: url, preset: preset, type: kAUSampler_DefaultMelodicBankMSB, in: bundle)
    }

    /// Load a Percussive SoundFont SF2 sample data file or a DLS file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 or the DLS file without the .sf2 / .dls extension
    ///   - preset: Number of the program to use
    ///   - bundle: The bundle from which to load the file. Defaults to main bundle.
    ///
    func loadPercussiveSoundFont(_ file: String, preset: Int = 0, in bundle: Bundle = .main) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultPercussionBankMSB, in: bundle)
    }
}
