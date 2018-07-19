//
//  AKAppleSampler.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// Sampler audio generation.
///
/// 1. init the audio unit like this: var sampler = AKAppleSampler()
/// 2. load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
/// 3. connect to the engine: AudioKit.output = sampler
/// 4. start the engine AudioKit.start()
///
open class AKAppleSampler: AKNode {

    // MARK: - Properties

    /// Internal audio unit
    private var internalAU: AUAudioUnit?

    fileprivate var token: AUParameterObserverToken?

    /// Sampler AV Audio Unit
    @objc open dynamic var samplerUnit = AVAudioUnitSampler()

    /// Tuning amount in semitones, from -24.0 to 24.0, Default: 0.0
    /// Doesn't transpose by playing another note (and the accoring zone and layer)
    /// but bends the sound up and down like tuning. 
    @objc open dynamic var tuning: Double {
        get {
            return Double(samplerUnit.globalTuning / 100.0)
        }
        set {
            samplerUnit.globalTuning = Float(newValue * 100.0)
        }
    }

    // MARK: - Initializers

    /// Initialize the sampler node
    override public init() {
        super.init()
        avAudioNode = samplerUnit
        internalAU = samplerUnit.auAudioUnit
        AudioKit.engine.attach(self.avAudioNode)
        //you still need to connect the output, and you must do this before starting the processing graph
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
    @objc open func loadWav(_ file: String) throws {
        guard let url = findFileURL(file, withExtension: "wav") else {
            AKLog("WAV file not found.")
            throw NSError(domain: NSURLErrorDomain, code: NSFileReadUnknownError, userInfo: nil)
        }
        do {
            try AKTry {
                try self.samplerUnit.loadAudioFiles(at: [url])
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
    @objc open func loadEXS24(_ file: String) throws {
        try loadInstrument(file, type: "exs")
    }

    /// Load an AKAudioFile
    ///
    /// - parameter file: an AKAudioFile
    ///
    @objc open func loadAudioFile(_ file: AKAudioFile) throws {
        do {
            try AKTry {
                try self.samplerUnit.loadAudioFiles(at: [file.url])
            }
        } catch let error as NSError {
            AKLog("Error loading audio file \"\(file.fileNamePlusExtension)\"")
            throw error
        }
    }

    /// Load an array of AKAudioFiles
    ///
    /// - parameter files: An array of AKAudioFiles
    ///
    /// If a file name ends with a note name (ex: "violinC3.wav")
    /// The file will be set to this note
    /// Handy to set multi-sampled instruments or a drum kit...
    @objc open func loadAudioFiles(_ files: [AKAudioFile] ) throws {
        let urls = files.map { $0.url }
        do {
            try AKTry {
                try self.samplerUnit.loadAudioFiles(at: urls)
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
    @objc open func loadPath(_ filePath: String) throws {
        do {
            try AKTry {
                try self.samplerUnit.loadInstrument(at: URL(fileURLWithPath: filePath))
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
            }
        } catch let error as NSError {
            AKLog("Error loading instrument resource \(file)")
            throw error
        }
    }

    /// Output Amplitude. Range: -90.0 -> +12 db, Default: 0 db
    @objc open dynamic var amplitude: Double = 0 {
        didSet {
            samplerUnit.masterGain = Float(amplitude)
        }
    }

    /// Normalized Output Volume. Range: 0 -> 1, Default: 1
    @objc open dynamic var volume: Double = 1 {
        didSet {
            let newGain = volume.denormalized(to: -90.0 ... 0.0)
            samplerUnit.masterGain = Float(newGain)
        }
    }

    /// Pan. Range: -1 -> 1, Default: 0
    @objc open dynamic var pan: Double = 0 {
        didSet {
            samplerUnit.stereoPan = Float(100.0 * pan)
        }
    }

    // MARK: - Playback

    /// Play a MIDI Note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to play
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channnel
    ///
    @objc open func play(noteNumber: MIDINoteNumber = 60,
                         velocity: MIDIVelocity = 127,
                         channel: MIDIChannel = 0) throws {
        try AKTry {
            if !AudioKit.engine.isRunning {
                AKLog("Cannot play note - AudioKit not running")
                throw AKError.AudioKitNotRunning
            } else {
                self.samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
            }
        }
    }
    /// Stop a MIDI Note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to stop
    ///   - channel: MIDI Channnel
    ///
    @objc open func stop(noteNumber: MIDINoteNumber = 60, channel: MIDIChannel = 0) throws {
        try AKTry {
            self.samplerUnit.stopNote(noteNumber, onChannel: channel)
        }
    }

}
