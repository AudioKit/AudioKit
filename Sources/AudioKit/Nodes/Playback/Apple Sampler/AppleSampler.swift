// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Sampler audio generation.
///
/// 1. init the audio unit like this: var sampler = AppleSampler()
/// 2. load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
/// 3. connect to the engine: engine.output = sampler
/// 4. start the engine engine.start()
///
open class AppleSampler: Node {
    // MARK: - Properties

    /// Internal audio unit
    public private(set) var internalAU: AUAudioUnit?

    private var _audioFiles: [AVAudioFile] = []

    /// Audio files to use in the sampler
    public var audioFiles: [AVAudioFile] {
        get {
            return _audioFiles
        }
        set {
            do {
                try loadAudioFiles(newValue)
            } catch {
                Log("Could not load audio files")
            }
        }
    }

    fileprivate var token: AUParameterObserverToken?

    /// Sampler AV Audio Unit
    public var samplerUnit = AVAudioUnitSampler()

    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { samplerUnit }

    /// Output Amplitude. Range: -90.0 -> +12 db, Default: 0 db
    public var amplitude: AUValue = 0 { didSet { samplerUnit.masterGain = Float(amplitude) } }

    /// Normalized Output Volume. Range: 0 -> 1, Default: 1
    public var volume: AUValue = 1 {
        didSet {
            let newGain = volume.denormalized(to: -90.0 ... 0.0)
            samplerUnit.masterGain = Float(newGain)
        }
    }

    /// Pan. Range: -1 -> 1, Default: 0
    public var pan: AUValue = 0 { didSet { samplerUnit.stereoPan = Float(100.0 * pan) } }

    /// Tuning amount in semitones, from -24.0 to 24.0, Default: 0.0
    /// Doesn't transpose by playing another note (and the according zone and layer)
    /// but bends the sound up and down like tuning.
    public var tuning: AUValue {
        get { return AUValue(samplerUnit.globalTuning / 100.0) }
        set { samplerUnit.globalTuning = Float(newValue * 100.0) }
    }

    // MARK: - Initializers

    /// Initialize the sampler node
    public init() {
        internalAU = samplerUnit.auAudioUnit
    }

    // Add URL based initializers

    // MARK: - Loaders

    /// Load a Soundfont, EXS24, etc.
    ///
    /// - parameter URL: Complete URL of the file to load
    ///
    public func loadInstrument(at url: URL) throws {
        try samplerUnit.loadInstrument(at: url)
    }

    /// Load an AVAudioFile
    ///
    /// - parameter file: an AVAudioFile
    ///
    public func loadAudioFile(_ file: AVAudioFile) throws {
        _audioFiles = [file]
        try samplerUnit.loadAudioFiles(at: [file.url])
    }

    /// Load an array of AVAudioFiles
    ///
    /// - parameter files: An array of AVAudioFiles
    ///
    /// If a file name ends with a note name (ex: "violinC3.wav")
    /// The file will be set to this note
    /// Handy to set multi-sampled instruments or a drum kit...
    public func loadAudioFiles(_ files: [AVAudioFile]) throws {
        _audioFiles = files
        let urls = files.map { $0.url }
        try samplerUnit.loadAudioFiles(at: urls)
    }

    /// Loads an instrument at a URL. The sampler can be configured by loading
    /// instruments from different types of files such as an aupreset, a DLS or SF2 sound bank,
    /// an EXS24 instrument, a single audio file, or an array of audio files.
    ///
    /// - parameter url: URL to the instrument file
    ///
    public func loadInstrument(url: URL) throws {
        try samplerUnit.loadInstrument(at: url)
    }

    // MARK: - Playback

    /// Play a MIDI Note or trigger a sample
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to play
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel
    ///
    /// NB: when using an audio file, noteNumber 60 will play back the file at normal
    /// speed, 72 will play back at double speed (1 octave higher), 48 will play back at
    /// half speed (1 octave lower) and so on
    open func play(noteNumber: MIDINoteNumber = 60,
                   velocity: MIDIVelocity = 127,
                   channel: MIDIChannel = 0)
    {
        samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }

    /// Stop a MIDI Note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to stop
    ///   - channel: MIDI Channel
    ///
    open func stop(noteNumber: MIDINoteNumber = 60, channel: MIDIChannel = 0) {
        samplerUnit.stopNote(noteNumber, onChannel: channel)
    }

    /// Set the pitch bend amount
    /// - Parameters:
    ///   - amount: Value of the pitch bend
    ///   - channel: MIDI Channel to apply the bend to
    public func setPitchbend(amount: MIDIWord, channel: MIDIChannel) {
        samplerUnit.sendPitchBend(amount, onChannel: channel)
    }

    /// Reset the internal sampler
    public func resetSampler() {
        samplerUnit.reset()
    }
}

// MARK: - Deprecatable junk

public extension AppleSampler {
    /// Utility method to find a file either in the main bundle or at an absolute path
    internal func findFileURL(_ path: String, withExtension ext: String, in bundle: Bundle = .main) -> URL? {
        if path.hasPrefix("/"), FileManager.default.fileExists(atPath: path + "." + ext) {
            return URL(fileURLWithPath: path + "." + ext)
        } else if let url = bundle.url(forResource: path, withExtension: ext) {
            return url
        }
        return nil
    }

    /// Variant of the above method to find a file either in the main bundle or at an absolute path
    /// by trying several file extensions. The first match will be returned.
    internal func findFileURL(_ path: String, withExtension extensions: [String], in bundle: Bundle = .main) -> URL? {
        for ext in extensions {
            if let url = findFileURL(path, withExtension: ext, in: bundle) {
                return url
            }
        }
        return nil
    }

    internal func loadInstrument(_ file: String, type: String, in bundle: Bundle = .main) throws {
        // Log("filename is \(file)")
        guard let url = findFileURL(file, withExtension: type, in: bundle) else {
            Log("File not found: \(file)")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        try samplerUnit.loadInstrument(at: url)
    }

    /// Load an AUPreset file
    ///
    /// - parameter file: Name of the AUPreset file without the .aupreset extension
    ///
    @available(*, deprecated, message: "Start using URLs since files can come from various places.")
    func loadAUPreset(_ file: String) throws {
        try loadInstrument(file, type: "aupreset")
    }

    /// Load a EXS24 sample data file
    ///
    /// - parameter file: Name of the EXS24 file without the .exs extension
    ///
    @available(*, deprecated, message: "Start using URLs since files can come from various places.")
    func loadEXS24(_ file: String) throws {
        try loadInstrument(file, type: "exs")
    }

    /// Load a Melodic SoundFont SF2 sample data file or a DLS file
    ///
    /// - Parameters:
    ///   - file: Name of the SoundFont SF2 or the DLS file without the .sf2 / .dls extension
    ///   - preset: Number of the program to use
    ///   - bundle: The bundle from which to load the file. Defaults to main bundle.
    ///
    @available(*, deprecated, message: "Start using URLs since files can come from various places.")
    func loadMelodicSoundFont(_ file: String, preset: Int, in bundle: Bundle = .main) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultMelodicBankMSB, in: bundle)
    }

    /// Load a file path. The sampler can be configured by loading
    /// instruments from different types of files such as an aupreset,
    /// an EXS24 instrument, a single audio file, or an array of audio files.
    ///
    /// - parameter filePath: Name of the file with the extension
    ///
    @available(*, deprecated, message: "Start using URLs since files can come from various places.")
    func loadPath(_ filePath: String) throws {
        try samplerUnit.loadInstrument(at: URL(fileURLWithPath: filePath))
    }

    /// Load a wav file
    ///
    /// - Parameters:
    ///   - file: Name of the file without an extension (assumed to be accessible from the bundle)
    ///   - bundle: The bundle from which to load the file. Defaults to main bundle.
    ///
    ///
    @available(*, deprecated, message: "Start using URLs since files can come from various places.")
    func loadWav(_ file: String, in bundle: Bundle = .main) throws {
        guard let url = findFileURL(file, withExtension: "wav", in: bundle) else {
            Log("WAV file not found.")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        try samplerUnit.loadAudioFiles(at: [url])
    }
}
