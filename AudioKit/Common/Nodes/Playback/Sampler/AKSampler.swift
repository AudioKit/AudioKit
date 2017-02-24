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
/// 1) init the audio unit like this: var sampler = AKSampler()
/// 2) load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
/// 3) connect to the engine: AudioKit.output = sampler
/// 4) start the engine AudioKit.start()
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
    open func loadPercussiveSoundFont(_ file: String, preset: Int) throws {
        try loadSoundFont(file, preset: preset, type: kAUSampler_DefaultPercussionBankMSB)
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

    static func getAUPresetXML() -> String {
        var templateStr: String
        templateStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        templateStr.append("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" " +
            "\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        templateStr.append("<plist version=\"1.0\">\n")
        templateStr.append("    <dict>\n")
        templateStr.append("        <key>AU version</key>\n")
        templateStr.append("        <real>1</real>\n")
        templateStr.append("        <key>Instrument</key>\n")
        templateStr.append("        <dict>\n")
        templateStr.append("            <key>Layers</key>\n")
        templateStr.append("            <array>\n")
        templateStr.append("                <dict>\n")
        templateStr.append("                    <key>Amplifier</key>\n")
        templateStr.append("                    <dict>\n")
        templateStr.append("                        <key>ID</key>\n")
        templateStr.append("                        <integer>0</integer>\n")
        templateStr.append("                        <key>enabled</key>\n")
        templateStr.append("                        <true/>\n")
        templateStr.append("                    </dict>\n")
        templateStr.append("                    <key>Connections</key>\n")
        templateStr.append("                    <array>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>816840704</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <false/>\n")
        templateStr.append("                            <key>scale</key>\n")
        templateStr.append("                            <real>12800</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>300</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>1343225856</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>scale</key>\n")
        templateStr.append("                            <real>-96</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>301</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>2</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>2</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>1343225856</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>scale</key>\n")
        templateStr.append("                            <real>-96</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>7</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>2</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>3</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>1343225856</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>scale</key>\n")
        templateStr.append("                            <real>-96</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>11</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>2</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>4</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>1344274432</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <false/>\n")
        templateStr.append("                            <key>max value</key>\n")
        templateStr.append("                            <real>0.50800001621246338</real>\n")
        templateStr.append("                            <key>min value</key>\n")
        templateStr.append("                            <real>-0.50800001621246338</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>10</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>7</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>241</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>816840704</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <false/>\n")
        templateStr.append("                            <key>max value</key>\n")
        templateStr.append("                            <real>12800</real>\n")
        templateStr.append("                            <key>min value</key>\n")
        templateStr.append("                            <real>-12800</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>224</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>8</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>816840704</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <false/>\n")
        templateStr.append("                            <key>max value</key>\n")
        templateStr.append("                            <real>100</real>\n")
        templateStr.append("                            <key>min value</key>\n")
        templateStr.append("                            <real>-100</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>242</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>6</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>816840704</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <false/>\n")
        templateStr.append("                            <key>max value</key>\n")
        templateStr.append("                            <real>50</real>\n")
        templateStr.append("                            <key>min value</key>\n")
        templateStr.append("                            <real>-50</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>268435456</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>5</integer>\n")
        templateStr.append("                            <key>control</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>destination</key>\n")
        templateStr.append("                            <integer>1343225856</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>inverse</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                            <key>scale</key>\n")
        templateStr.append("                            <real>-96</real>\n")
        templateStr.append("                            <key>source</key>\n")
        templateStr.append("                            <integer>536870912</integer>\n")
        templateStr.append("                            <key>transform</key>\n")
        templateStr.append("                            <integer>1</integer>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                    </array>\n")
        templateStr.append("                    <key>Envelopes</key>\n")
        templateStr.append("                    <array>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>Stages</key>\n")
        templateStr.append("                            <array>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>curve</key>\n")
        templateStr.append("                                    <integer>20</integer>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>0</integer>\n")
        templateStr.append("                                    <key>time</key>\n")
        templateStr.append("                                    <real>0.0</real>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>curve</key>\n")
        templateStr.append("                                    <integer>22</integer>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>1</integer>\n")
        templateStr.append("                                    <key>time</key>\n")
        templateStr.append("                                    <real>***ATTACK***</real>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>curve</key>\n")
        templateStr.append("                                    <integer>20</integer>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>2</integer>\n")
        templateStr.append("                                    <key>time</key>\n")
        templateStr.append("                                    <real>0.0</real>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>curve</key>\n")
        templateStr.append("                                    <integer>20</integer>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>3</integer>\n")
        templateStr.append("                                    <key>time</key>\n")
        templateStr.append("                                    <real>0.0</real>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>level</key>\n")
        templateStr.append("                                    <real>1</real>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>4</integer>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>curve</key>\n")
        templateStr.append("                                    <integer>20</integer>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>5</integer>\n")
        templateStr.append("                                    <key>time</key>\n")
        templateStr.append("                                    <real>***RELEASE***</real>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                                <dict>\n")
        templateStr.append("                                    <key>curve</key>\n")
        templateStr.append("                                    <integer>20</integer>\n")
        templateStr.append("                                    <key>stage</key>\n")
        templateStr.append("                                    <integer>6</integer>\n")
        templateStr.append("                                    <key>time</key>\n")
        templateStr.append("                                    <real>0.004999999888241291</real>\n")
        templateStr.append("                                </dict>\n")
        templateStr.append("                            </array>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                    </array>\n")
        templateStr.append("                    <key>Filters</key>\n")
        templateStr.append("                    <dict>\n")
        templateStr.append("                        <key>ID</key>\n")
        templateStr.append("                        <integer>0</integer>\n")
        templateStr.append("                        <key>cutoff</key>\n")
        templateStr.append("                        <real>20000</real>\n")
        templateStr.append("                        <key>enabled</key>\n")
        templateStr.append("                        <false/>\n")
        templateStr.append("                        <key>resonance</key>\n")
        templateStr.append("                        <real>0.0</real>\n")
        templateStr.append("                        <key>type</key>\n")
        templateStr.append("                        <integer>40</integer>\n")
        templateStr.append("                    </dict>\n")
        templateStr.append("                    <key>ID</key>\n")
        templateStr.append("                    <integer>0</integer>\n")
        templateStr.append("                    <key>LFOs</key>\n")
        templateStr.append("                    <array>\n")
        templateStr.append("                        <dict>\n")
        templateStr.append("                            <key>ID</key>\n")
        templateStr.append("                            <integer>0</integer>\n")
        templateStr.append("                            <key>enabled</key>\n")
        templateStr.append("                            <true/>\n")
        templateStr.append("                        </dict>\n")
        templateStr.append("                    </array>\n")
        templateStr.append("                    <key>Oscillator</key>\n")
        templateStr.append("                    <dict>\n")
        templateStr.append("                        <key>ID</key>\n")
        templateStr.append("                        <integer>0</integer>\n")
        templateStr.append("                        <key>enabled</key>\n")
        templateStr.append("                        <true/>\n")
        templateStr.append("                    </dict>\n")
        templateStr.append("                    <key>Zones</key>\n")
        templateStr.append("                    <array>\n")
        templateStr.append("                        ***ZONEMAPPINGS***\n")
        templateStr.append("                    </array>\n")
        templateStr.append("                </dict>\n")
        templateStr.append("            </array>\n")
        templateStr.append("            <key>name</key>\n")
        templateStr.append("            <string>Default Instrument</string>\n")
        templateStr.append("        </dict>\n")
        templateStr.append("        <key>coarse tune</key>\n")
        templateStr.append("        <integer>0</integer>\n")
        templateStr.append("        <key>data</key>\n")
        templateStr.append("        <data>\n")
        templateStr.append("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        templateStr.append("        </data>\n")
        templateStr.append("        <key>file-references</key>\n")
        templateStr.append("        <dict>\n")
        templateStr.append("            ***SAMPLEFILES***\n")
        templateStr.append("        </dict>\n")
        templateStr.append("        <key>fine tune</key>\n")
        templateStr.append("        <real>0.0</real>\n")
        templateStr.append("        <key>gain</key>\n")
        templateStr.append("        <real>0.0</real>\n")
        templateStr.append("        <key>manufacturer</key>\n")
        templateStr.append("        <integer>1634758764</integer>\n")
        templateStr.append("        <key>name</key>\n")
        templateStr.append("        <string>***INSTNAME***</string>\n")
        templateStr.append("        <key>output</key>\n")
        templateStr.append("        <integer>0</integer>\n")
        templateStr.append("        <key>pan</key>\n")
        templateStr.append("        <real>0.0</real>\n")
        templateStr.append("        <key>subtype</key>\n")
        templateStr.append("        <integer>1935764848</integer>\n")
        templateStr.append("        <key>type</key>\n")
        templateStr.append("        <integer>1635085685</integer>\n")
        templateStr.append("        <key>version</key>\n")
        templateStr.append("        <integer>0</integer>\n")
        templateStr.append("        <key>voice count</key>\n")
        templateStr.append("        <integer>64</integer>\n")
        templateStr.append("    </dict>\n")
        templateStr.append("</plist>\n")
        return templateStr
    }
}
