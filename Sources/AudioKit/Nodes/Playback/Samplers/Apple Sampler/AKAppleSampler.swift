// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Sampler audio generation.
///
/// 1. init the audio unit like this: var sampler = AKAppleSampler()
/// 2. load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
/// 3. connect to the engine: engine.output = sampler
/// 4. start the engine engine.start()
///
open class AKAppleSampler: AKNode {

    // MARK: - Properties

    /// Internal audio unit
    public private(set) var internalAU: AUAudioUnit?

    private var _audioFiles: [AVAudioFile] = []

    public var audioFiles: [AVAudioFile] {
        get {
            return _audioFiles
        }
        set {
            do {
                try loadAudioFiles(newValue)
            } catch {
                AKLog("Could not load audio files")
            }
        }
    }

    fileprivate var token: AUParameterObserverToken?

    /// Sampler AV Audio Unit
    public var samplerUnit = AVAudioUnitSampler()

    /// Tuning amount in semitones, from -24.0 to 24.0, Default: 0.0
    /// Doesn't transpose by playing another note (and the accoring zone and layer)
    /// but bends the sound up and down like tuning.
    public var tuning: AUValue {
        get {
            return AUValue(samplerUnit.globalTuning / 100.0)
        }
        set {
            samplerUnit.globalTuning = Float(newValue * 100.0)
        }
    }

    // MARK: - Initializers

    /// Initialize the sampler node
    public init(file: String? = nil) {
        super.init(avAudioNode: AVAudioNode())
        avAudioUnit = samplerUnit
        avAudioNode = samplerUnit
        internalAU = samplerUnit.auAudioUnit

        if let newFile = file {
            do {
                try loadWav(newFile)
            } catch {
                AKLog("Could not load \(newFile)")
            }
        }
    }

    /// Utility method to find a file either in the main bundle or at an absolute path
    internal func findFileURL(_ path: String, withExtension ext: String) -> URL? {
        if path.hasPrefix("/") && FileManager.default.fileExists(atPath: path + "." + ext) {
            return URL(fileURLWithPath: path + "." + ext)
        } else if let url = Bundle.main.url(forResource: path, withExtension: ext) {
            return url
        }
        return nil
    }

    /// Load a wav file
    ///
    /// - parameter file: Name of the file without an extension (assumed to be accessible from the bundle)
    ///
    public func loadWav(_ file: String) throws {
        guard let url = findFileURL(file, withExtension: "wav") else {
            AKLog("WAV file not found.")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        do {
            try AKTry {
                try self.samplerUnit.loadAudioFiles(at: [url])
                self.samplerUnit.reset()
            }
        } catch let error as NSError {
            AKLog("Error loading wav file at \(url)")
            throw error
        }
    }

    /// Load an EXS24 sample data file
    ///
    /// - parameter file: Name of the EXS24 file without the .exs extension
    ///
    public func loadEXS24(_ file: String) throws {
        try loadInstrument(file, type: "exs")
    }

    /// Load an AVAudioFile
    ///
    /// - parameter file: an AVAudioFile
    ///
    public func loadAudioFile(_ file: AVAudioFile) throws {
        _audioFiles = [file]

        do {
            try AKTry {
                try self.samplerUnit.loadAudioFiles(at: [file.url])
                self.samplerUnit.reset()
            }
        } catch let error as NSError {
            AKLog("Error loading audio file \"\(file.url.lastPathComponent)\"")
            throw error
        }
    }

    /// Load an array of AVAudioFiles
    ///
    /// - parameter files: An array of AVAudioFiles
    ///
    /// If a file name ends with a note name (ex: "violinC3.wav")
    /// The file will be set to this note
    /// Handy to set multi-sampled instruments or a drum kit...
    public func loadAudioFiles(_ files: [AVAudioFile] ) throws {
        _audioFiles = files
        let urls = files.map { $0.url }
        do {
            try AKTry {
                try self.samplerUnit.loadAudioFiles(at: urls)
                self.samplerUnit.reset()
            }
        } catch let error as NSError {
            AKLog("Error loading audio files \(urls)")
            throw error
        }
    }

    /// Load a file path. The sampler can be configured by loading
    /// instruments from different types of files such as an aupreset, a DLS or SF2 sound bank,
    /// an EXS24 instrument, a single audio file, or an array of audio files.
    ///
    /// - parameter filePath: Name of the file with the extension
    ///
    public func loadPath(_ filePath: String) throws {
        do {
            try AKTry {
                try self.samplerUnit.loadInstrument(at: URL(fileURLWithPath: filePath))
                self.samplerUnit.reset()
            }
        } catch {
            AKLog("Error AKSampler.loadPath loading file at \(filePath)")
            throw error
        }
    }

    internal func loadInstrument(_ file: String, type: String) throws {
        //AKLog("filename is \(file)")
        guard let url = findFileURL(file, withExtension: type) else {
            AKLog("File not found: \(file)")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        do {
            try AKTry {
                try self.samplerUnit.loadInstrument(at: url)
                self.samplerUnit.reset()
            }
        } catch let error as NSError {
            AKLog("Error loading instrument resource \(file)")
            throw error
        }
    }

    /// Output Amplitude. Range: -90.0 -> +12 db, Default: 0 db
    public var amplitude: AUValue = 0 {
        didSet {
            samplerUnit.masterGain = Float(amplitude)
        }
    }

    /// Normalized Output Volume. Range: 0 -> 1, Default: 1
    public var volume: AUValue = 1 {
        didSet {
            let newGain = volume.denormalized(to: -90.0 ... 0.0)
            samplerUnit.masterGain = Float(newGain)
        }
    }

    /// Pan. Range: -1 -> 1, Default: 0
    public var pan: AUValue = 0 {
        didSet {
            samplerUnit.stereoPan = Float(100.0 * pan)
        }
    }

    // MARK: - Playback

    /// Play a MIDI Note or trigger a sample
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to play
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channnel
    ///
    /// NB: when using an audio file, noteNumber 60 will play back the file at normal
    /// speed, 72 will play back at double speed (1 octave higher), 48 will play back at
    /// half speed (1 octave lower) and so on
    public func play(noteNumber: MIDINoteNumber = 60,
                     velocity: MIDIVelocity = 127,
                     channel: MIDIChannel = 0) throws {
        self.samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }
    /// Stop a MIDI Note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to stop
    ///   - channel: MIDI Channnel
    ///
    public func stop(noteNumber: MIDINoteNumber = 60, channel: MIDIChannel = 0) throws {
        try AKTry {
            self.samplerUnit.stopNote(noteNumber, onChannel: channel)
        }
    }

    // MARK: - SoundFont Support

    // NOTE: The following methods might seem like they belong in the
    // SoundFont extension, but when place there, iOS12 beta crashed

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
            samplerUnit.reset()
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
    public func loadSoundFont(_ file: String, preset: Int, bank: Int) throws {
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
            samplerUnit.reset()
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
    public func loadMelodicSoundFont(_ file: String, preset: Int) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultMelodicBankMSB)
    }

    /// Load a Percussive SoundFont SF2 sample data file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 file without the .sf2 extension
    ///   - preset: Number of the program to use
    ///
    public func loadPercussiveSoundFont(_ file: String, preset: Int = 0) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultPercussionBankMSB)
    }

    public func setPitchbend(amount: MIDIWord, channel: MIDIChannel) {
        samplerUnit.sendPitchBend(amount, onChannel: channel)
    }

}
