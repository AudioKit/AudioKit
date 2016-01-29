//
//  AKSampler.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// Sampler audio generation.
///
/// 1) init the audio unit like this: var sampler = AKSampler()
/// 2) load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
/// 3) connect to the avengine: AudioKit.output = sampler
/// 4) start the engine AudioKit.start()
///
public class AKSampler: AKNode {
    
    // MARK: - Properties
    
    private var internalAU: AUAudioUnit?

    private var token: AUParameterObserverToken?
    
    /// Sampler AV Audio Unit
    public var samplerUnit = AVAudioUnitSampler()
    
    // MARK: - Initializers
    
    /// Initialize the sampler node
    public override init() {
        super.init()
        self.avAudioNode = samplerUnit
        self.internalAU = samplerUnit.AUAudioUnit
        AudioKit.engine.attachNode(self.avAudioNode)
        //you still need to connect the output, and you must do this before starting the processing graph
    }
    
    /// Load a wav file
    ///
    /// - parameter file: Name of the file without an extension (assumed to be accessible from the bundle)
    ///
    public func loadWav(file: String) {
        guard let url = NSBundle.mainBundle().URLForResource(file, withExtension: "wav") else {
                fatalError("file not found.")
        }
        let files: [NSURL] = [url]
        do {
            try samplerUnit.loadAudioFilesAtURLs(files)
        } catch {
            print("error")
        }
    }
    
    /// Load an EXS24 sample data file
    ///
    /// - parameter file: Name of the EXS24 file without the .exs extension
    ///
    public func loadEXS24(file: String) {
        loadInstrument(file, type: "exs")
    }
    
    /// Load a SoundFont SF2 sample data file
    ///
    /// - parameter file: Name of the SoundFont SF2 file without the .sf2 extension
    ///
    public func loadSoundfont(file: String) {
        loadInstrument(file, type: "sf2")
    }
    
    internal func loadInstrument(file: String, type: String) {
        print("filename is \(file)")
        guard let url = NSBundle.mainBundle().URLForResource(file, withExtension: type) else {
                fatalError("file not found.")
        }
        do {
            try samplerUnit.loadInstrumentAtURL(url)
        } catch {
            print("error")
        }
    }
    
    /// Output Amplitude.
    public var amplitude: Double = 1 {
        didSet {
            samplerUnit.masterGain = Float(amplitude)
            print(samplerUnit.masterGain)
        }
    }
    // MARK: - Playback
    
    /// Play a MIDI Note
    ///
    /// - parameter note: MIDI Note Number to play
    /// - parameter velocity: MIDI Velocity
    /// - parameter channel: MIDI Channnel
    ///
    public func playNote(note: Int = 60, velocity: Int = 127, channel: Int = 0) {
        samplerUnit.startNote(UInt8(note), withVelocity: UInt8(velocity), onChannel: UInt8(channel))
    }
    
    /// Stop a MIDI Note
    /// - parameter note: MIDI Note Number to stop
    /// - parameter channel: MIDI Channnel
    ///
    public func stopNote(note: Int = 60, channel: Int = 0) {
        samplerUnit.stopNote(UInt8(note), onChannel: UInt8(channel))
    }
    
}
