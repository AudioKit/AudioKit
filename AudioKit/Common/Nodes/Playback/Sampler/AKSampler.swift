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
    
    /// Load a file path
    ///
    /// - parameter file: Name of the file with the extension
    ///
    public func loadPath(filePath: String) {
        do {
            try samplerUnit.loadInstrumentAtURL(NSURL(fileURLWithPath: filePath))
        } catch {
            print("error")
        }
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
    
    /* createAUPresetFromDict
     was moved to AKAUPresetBuilder
    */
    static public func createAUPresetFromDict(dict: NSDictionary, path: String, instName: String, attack: Double? = 0, release: Double? = 0){
        NSException(name: "Deprecated", reason: "createAUPresetFromDict was moved to AKAUPresetBuilder. You can safely replace all instances of AKSampler.createAUPresetFromDict with AKAUPresetBuilder.createAUPresetFromDict. Thank you.", userInfo: nil).raise()
    }//end func createAUPresetFromDict
    
    // This functions returns 1 dictionary entry for a particular sample zone. You then add this to an array, and feed that
    // into createAUPresetFromDict
    public static func generateTemplateDictionary(
        rootNote: Int,
        filename: String,
        startNote: Int,
        endNote: Int) -> NSMutableDictionary {
        NSException(name: "Deprecated", reason: "generateTemplateDictionary was moved to AKAUPresetBuilder. You can safely replace all instances of AKSampler.generateTemplateDictionary with AKAUPresetBuilder.generateTemplateDictionary. Thank you.", userInfo: nil).raise()
        return NSMutableDictionary()
    }
    
    /// Output Amplitude.
    /// Range: -90.0 -> +12 db
    /// Default: 0 db
    public var amplitude: Double = 0 {
        didSet {
            samplerUnit.masterGain = Float(amplitude)
        }
    }
    
    /// Normalized Output Volume.
    /// Range:   0 - 1
    /// Default: 1
    public var volume: Double = 1 {
        didSet {
            var newGain = volume
            newGain.denormalize(-90.0, max: 0.0, taper: 1)
            samplerUnit.masterGain = Float(newGain)
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
    
    static func getAUPresetXML() -> String{
        var templateStr:String
        templateStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        templateStr.appendContentsOf("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        templateStr.appendContentsOf("<plist version=\"1.0\">\n")
        templateStr.appendContentsOf("    <dict>\n")
        templateStr.appendContentsOf("        <key>AU version</key>\n")
        templateStr.appendContentsOf("        <real>1</real>\n")
        templateStr.appendContentsOf("        <key>Instrument</key>\n")
        templateStr.appendContentsOf("        <dict>\n")
        templateStr.appendContentsOf("            <key>Layers</key>\n")
        templateStr.appendContentsOf("            <array>\n")
        templateStr.appendContentsOf("                <dict>\n")
        templateStr.appendContentsOf("                    <key>Amplifier</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <true/>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        templateStr.appendContentsOf("                    <key>Connections</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>816840704</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <false/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>12800</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>300</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>1343225856</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>-96</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>301</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>2</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>2</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>1343225856</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>-96</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>7</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>2</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>3</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>1343225856</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>-96</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>11</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>2</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>4</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>1344274432</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <false/>\n")
        templateStr.appendContentsOf("                            <key>max value</key>\n")
        templateStr.appendContentsOf("                            <real>0.50800001621246338</real>\n")
        templateStr.appendContentsOf("                            <key>min value</key>\n")
        templateStr.appendContentsOf("                            <real>-0.50800001621246338</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>10</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>7</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>241</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>816840704</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <false/>\n")
        templateStr.appendContentsOf("                            <key>max value</key>\n")
        templateStr.appendContentsOf("                            <real>12800</real>\n")
        templateStr.appendContentsOf("                            <key>min value</key>\n")
        templateStr.appendContentsOf("                            <real>-12800</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>224</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>8</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>816840704</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <false/>\n")
        templateStr.appendContentsOf("                            <key>max value</key>\n")
        templateStr.appendContentsOf("                            <real>100</real>\n")
        templateStr.appendContentsOf("                            <key>min value</key>\n")
        templateStr.appendContentsOf("                            <real>-100</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>242</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>6</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>816840704</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <false/>\n")
        templateStr.appendContentsOf("                            <key>max value</key>\n")
        templateStr.appendContentsOf("                            <real>50</real>\n")
        templateStr.appendContentsOf("                            <key>min value</key>\n")
        templateStr.appendContentsOf("                            <real>-50</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>268435456</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>5</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>1343225856</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>-96</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>536870912</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                    </array>\n")
        templateStr.appendContentsOf("                    <key>Envelopes</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>Stages</key>\n")
        templateStr.appendContentsOf("                            <array>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>0</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>0.0</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>22</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>1</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>***ATTACK***</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>2</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>0.0</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>3</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>0.0</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>level</key>\n")
        templateStr.appendContentsOf("                                    <real>1</real>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>4</integer>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>5</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>***RELEASE***</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>6</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>0.004999999888241291</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                            </array>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                    </array>\n")
        templateStr.appendContentsOf("                    <key>Filters</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>cutoff</key>\n")
        templateStr.appendContentsOf("                        <real>20000</real>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <false/>\n")
        templateStr.appendContentsOf("                        <key>resonance</key>\n")
        templateStr.appendContentsOf("                        <real>0.0</real>\n")
        templateStr.appendContentsOf("                        <key>type</key>\n")
        templateStr.appendContentsOf("                        <integer>40</integer>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        templateStr.appendContentsOf("                    <key>ID</key>\n")
        templateStr.appendContentsOf("                    <integer>0</integer>\n")
        templateStr.appendContentsOf("                    <key>LFOs</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        templateStr.appendContentsOf("                    </array>\n")
        templateStr.appendContentsOf("                    <key>Oscillator</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <true/>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        templateStr.appendContentsOf("                    <key>Zones</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        templateStr.appendContentsOf("                        ***ZONEMAPPINGS***\n")
        templateStr.appendContentsOf("                    </array>\n")
        templateStr.appendContentsOf("                </dict>\n")
        templateStr.appendContentsOf("            </array>\n")
        templateStr.appendContentsOf("            <key>name</key>\n")
        templateStr.appendContentsOf("            <string>Default Instrument</string>\n")
        templateStr.appendContentsOf("        </dict>\n")
        templateStr.appendContentsOf("        <key>coarse tune</key>\n")
        templateStr.appendContentsOf("        <integer>0</integer>\n")
        templateStr.appendContentsOf("        <key>data</key>\n")
        templateStr.appendContentsOf("        <data>\n")
        templateStr.appendContentsOf("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        templateStr.appendContentsOf("        </data>\n")
        templateStr.appendContentsOf("        <key>file-references</key>\n")
        templateStr.appendContentsOf("        <dict>\n")
        templateStr.appendContentsOf("            ***SAMPLEFILES***\n")
        templateStr.appendContentsOf("        </dict>\n")
        templateStr.appendContentsOf("        <key>fine tune</key>\n")
        templateStr.appendContentsOf("        <real>0.0</real>\n")
        templateStr.appendContentsOf("        <key>gain</key>\n")
        templateStr.appendContentsOf("        <real>0.0</real>\n")
        templateStr.appendContentsOf("        <key>manufacturer</key>\n")
        templateStr.appendContentsOf("        <integer>1634758764</integer>\n")
        templateStr.appendContentsOf("        <key>name</key>\n")
        templateStr.appendContentsOf("        <string>***INSTNAME***</string>\n")
        templateStr.appendContentsOf("        <key>output</key>\n")
        templateStr.appendContentsOf("        <integer>0</integer>\n")
        templateStr.appendContentsOf("        <key>pan</key>\n")
        templateStr.appendContentsOf("        <real>0.0</real>\n")
        templateStr.appendContentsOf("        <key>subtype</key>\n")
        templateStr.appendContentsOf("        <integer>1935764848</integer>\n")
        templateStr.appendContentsOf("        <key>type</key>\n")
        templateStr.appendContentsOf("        <integer>1635085685</integer>\n")
        templateStr.appendContentsOf("        <key>version</key>\n")
        templateStr.appendContentsOf("        <integer>0</integer>\n")
        templateStr.appendContentsOf("        <key>voice count</key>\n")
        templateStr.appendContentsOf("        <integer>64</integer>\n")
        templateStr.appendContentsOf("    </dict>\n")
        templateStr.appendContentsOf("</plist>\n")
        return templateStr
    }
}
