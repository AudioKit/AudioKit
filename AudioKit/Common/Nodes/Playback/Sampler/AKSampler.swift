//
//  AKSampler.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation
import CoreAudio

/// Sampler audio generation.
///
/// 1. init the audio unit like this: var sampler = AKSampler()
/// 2. load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
/// 3. connect to the engine before starting the processing graph: AudioKit.output = sampler
/// 4. start the engine AudioKit.start()
///
open class AKSampler: AKNode {

    // MARK: - Properties

    /// Internal audio unit
    private var internalAU: AUAudioUnit?

    fileprivate var token: AUParameterObserverToken?

    /// Sampler AV Audio Unit
    open dynamic var samplerUnit = AVAudioUnitSampler()

    /// Transposition amount in semitones, from -24 to 24, Default: 0
    open dynamic var tuning: Double {
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

    /// Load a wav file
    ///
    /// - parameter file: Name of the file without an extension (assumed to be accessible from the bundle)
    ///
    open func loadWav(_ file: String) throws {
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else {
                fatalError("file not found.")
        }
        do {
            try samplerUnit.loadAudioFiles(at: [url])
        } catch let error as NSError {
            AKLog("Error loading wav file at \(url)")
            throw error
        }
    }

    /// Load an EXS24 sample data file
    ///
    /// - parameter file: Name of the EXS24 file without the .exs extension
    ///
    open func loadEXS24(_ file: String) throws {
        try loadInstrument(file, type: "exs")
    }

    /// Load an AKAudioFile
    ///
    /// - parameter file: an AKAudioFile
    ///
    open func loadAudioFile(_ file: AKAudioFile) throws {
        do {
            try samplerUnit.loadAudioFiles(at: [file.url])
        } catch let error as NSError {
            AKLog("Error loading audio file \"\(file.fileNamePlusExtension)\"")
            throw error
        }
    }

    /// Load an array of AKAudioFiles
    ///
    /// - parameter file: an array of AKAudioFile
    ///
    /// If a file name ends with a note name (ex: "violinC3.wav")
    /// The file will be set to this note
    /// Handy to set multi-sampled instruments or a drum kit...
    open func loadAudioFiles(_ files: [AKAudioFile] ) throws {
        let urls = files.map { $0.url }
        do {
            try samplerUnit.loadAudioFiles(at: urls)
        } catch let error as NSError {
            AKLog("Error loading audio files \(urls)")
            throw error
        }
    }

    /// Load a file path
    ///
    /// - parameter filePath: Name of the file with the extension
    ///
    open func loadPath(_ filePath: String) {
        do {
            try samplerUnit.loadInstrument(at: URL(fileURLWithPath: filePath))
        } catch {
            AKLog("Error loading audio file at \(filePath)")
        }
    }

    internal func loadInstrument(_ file: String, type: String) throws {
        //AKLog("filename is \(file)")
        guard let url = Bundle.main.url(forResource: file, withExtension: type) else {
            fatalError("file not found.")
        }
        do {
            try samplerUnit.loadInstrument(at: url)
        } catch let error as NSError {
            AKLog("Error loading instrument resource \(file)")
            throw error
        }
    }

    /// Output Amplitude. Range: -90.0 -> +12 db, Default: 0 db
    open dynamic var amplitude: Double = 0 {
        didSet {
            samplerUnit.masterGain = Float(amplitude)
        }
    }

    /// Normalized Output Volume. Range: 0 -> 1, Default: 1
    open dynamic var volume: Double = 1 {
        didSet {
            let newGain = volume.denormalized(minimum: -90.0, maximum: 0.0, taper: 1)
            samplerUnit.masterGain = Float(newGain)
        }
    }

    /// Pan. Range: -1 -> 1, Default: 0
    open dynamic var pan: Double = 0 {
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
    open func play(noteNumber: MIDINoteNumber = 60,
                   velocity: MIDIVelocity = 127,
                   channel: MIDIChannel = 0) {
        samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }

    /// Stop a MIDI Note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number to stop
    ///   - channel: MIDI Channnel
    ///
    open func stop(noteNumber: MIDINoteNumber = 60, channel: MIDIChannel = 0) {
        samplerUnit.stopNote(noteNumber, onChannel: channel)
    }

}
