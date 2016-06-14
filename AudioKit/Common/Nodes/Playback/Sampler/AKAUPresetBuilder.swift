//
//  AKAUPresetBuilder.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKAUPresetBuilder {
    
    public var presetXML = ""
    public var layers = [String]()
    public var connections = [String]()
    public var envelopes = [String]()
    public var lfos = [String]()
    public var zones = [String]()
    public var fileRefs = [String]()
    public var filters = [String]()
    
    /// Create preset with the given components
    /// - parameter name:        Coded instrument name
    /// - parameter connections: Connection XML
    /// - parameter envelopes:   Envelopes XML
    /// - parameter filter:      Filter XML
    /// - parameter lfos:        Low Frequency Oscillator XML
    /// - parameter zones:       Zones XML
    /// - parameter filerefs:    File references XML
    ///
    init(name: String = "Coded Instrument Name",
         connections: String = "***CONNECTIONS***\n",
         envelopes: String = "***ENVELOPES***\n",
         filter: String = "***FILTER***\n",
         lfos: String = "***LFOS***\n",
         zones: String = "***ZONES***\n",
         filerefs: String = "***FILEREFS***\n") {
        presetXML = AKAUPresetBuilder.buildInstrument(name,
                                                      connections: connections,
                                                      envelopes: envelopes,
                                                      filter: filter,
                                                      lfos: lfos,
                                                      zones: zones,
                                                      filerefs: filerefs)
    }
    
    /// Create an AUPreset from a collection of dictionaries.
    /// dict is a collection of other dictionaries that have the format like this:
    /// ***Key:Value***
    /// filename:string
    /// rootnote:int
    /// startnote:int (optional)
    /// endnote:int (optional)
    ///
    /// - parameter dict:           Collection of dictionaries with format as given above
    /// - parameter path:           Where the AUPreset will be created
    /// - parameter instrumentName: The name of the AUPreset
    /// - parameter attack:         Attack time in seconds
    /// - parameter release:        Release time in seconds
    static public func createAUPresetFromDict(_ dict: NSDictionary,
                                              path: String,
                                              instrumentName: String,
                                              attack: Double? = 0,
                                              release: Double? = 0) {
        let rootNoteKey = "rootnote"
        let startNoteKey = "startnote"
        let endNoteKey = "endnote"
        let filenameKey = "filename"
        var loadSoundsArr = Array<NSMutableDictionary>()
        var sampleZoneXML = ""
        var sampleIDXML = ""
        var sampleIteration = 0
        let sampleNumStart = 268435457
        
        //iterate over the sounds
        for i in 0 ..< dict.count {
            let sound = dict.allValues[i]
            var soundDict: NSMutableDictionary
            var alreadyLoaded = false
            var sampleNum = 0
            soundDict = sound.mutableCopy() as! NSMutableDictionary
            //check if this sample is already loaded
            for loadedSoundDict in loadSoundsArr {
                let alreadyLoadedSound: String = loadedSoundDict.object(forKey: filenameKey) as! String
                let newLoadingSound: String = soundDict.object(forKey: filenameKey) as! String
                if alreadyLoadedSound == newLoadingSound {
                    alreadyLoaded = true
                    sampleNum = loadedSoundDict.object(forKey: "sampleNum") as! Int
                }
            }
            
            if sound.object(forKey: startNoteKey) == nil || sound.object(forKey: endNoteKey) == nil {
                soundDict.setObject(sound.object(forKey: rootNoteKey)!, forKey: startNoteKey)
                soundDict.setObject(sound.object(forKey: rootNoteKey)!, forKey: endNoteKey)
            }
            if sound.object(forKey: rootNoteKey) == nil {
                //error
            } else {
                soundDict.setObject(sound.object(forKey: rootNoteKey)!, forKey: rootNoteKey)
            }
            
            if !alreadyLoaded { //if this is a new sound, then add it to samplefile xml
                sampleNum = sampleNumStart + sampleIteration
                let idXML = AKAUPresetBuilder.generateFileRef(sampleNum, samplePath: sound.object(forKey: "filename")! as! String)
                sampleIDXML.append(idXML)
                
                sampleIteration += 1
            }
            
            let startNote = soundDict.object(forKey: startNoteKey)! as! Int
            let endNote = soundDict.object(forKey: endNoteKey)! as! Int
            let rootNote = soundDict.object(forKey: rootNoteKey)! as! Int
            let tempSampleZoneXML: String = AKAUPresetBuilder.generateZone(i, rootNote: rootNote, startNote: startNote, endNote: endNote, wavRef: sampleNum)
            
            sampleZoneXML.append(tempSampleZoneXML)
            soundDict.setObject(sampleNum, forKey: "sampleNum")
            loadSoundsArr.append(soundDict)
        }
        
        let envelopesXML = AKAUPresetBuilder.generateEnvelope(0, delay: 0, attack: attack!, hold: 0, decay: 0, sustain: 1, release: release!)
        let str = AKAUPresetBuilder.buildInstrument(instrumentName, envelopes: envelopesXML, zones: sampleZoneXML, filerefs: sampleIDXML)
        
        //write to file
        do {
            print("Writing to \(path)")
            try str.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Could not write to \(path)")
            print(error)
        }
    }
    
    /// This functions returns 1 dictionary entry for a particular sample zone. You then add this to an array, and feed that into createAUPresetFromDict
    /// - parameter rootNote:  Note at which the sample playback is unchanged
    /// - parameter filename:  Name of the file
    /// - parameter startNote: First note in range
    /// - parameter endNote:   Last note in range
    ///
    public static func generateDictionary(
        _ rootNote: Int,
        filename: String,
        startNote: Int,
        endNote: Int) -> NSMutableDictionary {
        
        let rootNoteKey = "rootnote"
        let startNoteKey = "startnote"
        let endNoteKey = "endnote"
        let filenameKey = "filename"
        let defaultObjects: [NSObject] = [rootNote, startNote, endNote, filename]
        let keys = [rootNoteKey, startNoteKey, endNoteKey, filenameKey]
        return NSMutableDictionary.init(objects: defaultObjects, forKeys: keys)
    }
    
    static func spaces(_ count: Int) -> String {
        return String(repeating: (" " as Character), count: count)
    }
    
    static public func buildInstrument(_ name: String = "Coded Instrument Name",
                                       connections: String = "",
                                       envelopes: String = "",
                                       filter: String = "",
                                       lfos: String = "",
                                       zones: String = "***ZONES***\n",
                                       filerefs: String = "***FILEREFS***\n",
                                       layers: String = "") -> String {
        var presetXML = openPreset()
        presetXML.append(openInstrument())
        presetXML.append(openLayers())
        
        if layers == "" {
            presetXML.append(openLayer())
            presetXML.append(openConnections())
            presetXML.append((connections == "" ? genDefaultConnections() : connections))
            presetXML.append(closeConnections())
            presetXML.append(openEnvelopes())
            presetXML.append((envelopes == "" ? generateEnvelope() : envelopes))
            presetXML.append(closeEnvelopes())
            presetXML.append((filter == "" ? generateFilter() : filter))
            presetXML.append(generateID())
            presetXML.append(openLFOs())
            presetXML.append((lfos == "" ? generateLFO() : lfos))
            presetXML.append(closeLFOs())
            presetXML.append(generateOscillator())
            presetXML.append(openZones())
            presetXML.append(zones)
            //presetXML.appendContentsOf(generateZone(<#T##id: Int##Int#>, rootNote: <#T##Int#>, startNote: <#T##Int#>, endNote: <#T##Int#>, wavRef: <#T##Int#>))
            presetXML.append(closeZones())
            presetXML.append(closeLayer())
        } else {
            presetXML.append(layers)
        }
        
        presetXML.append(closeLayers())
        presetXML.append(closeInstrument())
        presetXML.append(genCoarseTune())
        presetXML.append(genDataBlob())
        presetXML.append(openFileRefs())
        presetXML.append(filerefs)
        //presetXML.appendContentsOf(generateFileRef(<#T##wavRef: Int##Int#>, samplePath: <#T##String#>))
        presetXML.append(closeFileRefs())
        presetXML.append(generateFineTune())
        presetXML.append(generateGain())
        presetXML.append(generateManufacturer())
        presetXML.append(generateInstrumentName(name))
        presetXML.append(generateOutput())
        presetXML.append(generatePan())
        presetXML.append(generateTypeAndSubType())
        presetXML.append(generateVoiceCount())
        presetXML.append(closePreset())
        return presetXML
    }
    static public func openPreset() -> String {
        var str: String = ""
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        str.append("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        str.append("<plist version=\"1.0\">\n")
        str.append("    <dict>\n")
        str.append("        <key>AU version</key>\n")
        str.append("        <real>1</real>\n")
        return str
    }
    static public func openInstrument() -> String {
        var str: String = ""
        str.append("        <key>Instrument</key>\n")
        str.append("        <dict>\n")
        return str
    }
    static public func openLayers() -> String {
        var str: String = ""
        str.append("            <key>Layers</key>\n")
        str.append("            <array>\n")
        return str
    }

    static public func openLayer() -> String {
        var str = ""
        str.append("\(spaces(16))<dict>\n")
        str.append("\(spaces(16))    <key>Amplifier</key>\n")
        str.append("\(spaces(16))    <dict>\n")
        str.append("\(spaces(16))        <key>ID</key>\n")
        str.append("\(spaces(16))        <integer>0</integer>\n")
        str.append("\(spaces(16))        <key>enabled</key>\n")
        str.append("\(spaces(16))        <true/>\n")
        str.append("\(spaces(16))    </dict>\n")
        return str
    }
    static public func openConnections() -> String {
        var str = ""
        str.append("                    <key>Connections</key>\n")
        str.append("                    <array>\n")
        return str
    }
    static public func generateConnectionDict(_ id: Int,
                                              source: Int,
                                              destination: Int,
                                              scale: Int,
                                              transform: Int = 1,
                                              invert: Bool = false) -> String {
        var str = ""
        str.append("\(spaces(34))<dict>\n")
        str.append("\(spaces(34))    <key>ID</key>\n")
        str.append("\(spaces(34))    <integer>\(id)</integer>\n")
        str.append("\(spaces(34))    <key>control</key>\n")
        str.append("\(spaces(34))    <integer>0</integer>\n")
        str.append("\(spaces(34))    <key>destination</key>\n")
        str.append("\(spaces(34))    <integer>\(destination)</integer>\n")
        str.append("\(spaces(34))    <key>enabled</key>\n")
        str.append("\(spaces(34))    <true/>\n")
        str.append("\(spaces(34))    <key>inverse</key>\n")
        str.append("\(spaces(34))    <\((invert ? "true" : "false"))/>\n")
        str.append("\(spaces(34))    <key>scale</key>\n")
        str.append("\(spaces(34))    <real>\(scale)</real>\n")
        str.append("\(spaces(34))    <key>source</key>\n")
        str.append("\(spaces(34))    <integer>\(source)</integer>\n")
        str.append("\(spaces(34))    <key>transform</key>\n")
        str.append("\(spaces(34))    <integer>1</integer>\n")
        str.append("\(spaces(34))</dict>\n")
        return str
    }
    static public func closeConnections() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }
    static public func openEnvelopes() -> String {
        var str = ""
        str.append("                    <key>Envelopes</key>\n")
        str.append("                    <array>\n")
        return str
    }
    static public func generateEnvelope(_ id: Int = 0,
                                        delay: Double = 0.0,
                                        attack: Double = 0.0,
                                        hold: Double = 0.0,
                                        decay: Double = 0.0,
                                        sustain: Double = 1.0,
                                        release: Double = 0.0) -> String {
        var str = ""
        str.append("\(spaces(34))<dict>\n")
        str.append("\(spaces(34))    <key>ID</key>\n")
        str.append("\(spaces(34))    <integer>\(id)</integer>\n")
        str.append("\(spaces(34))    <key>Stages</key>\n")
        str.append("\(spaces(34))    <array>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>curve</key>\n")
        str.append("\(spaces(34))            <integer>20</integer>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>0</integer>\n")
        str.append("\(spaces(34))            <key>time</key>\n")
        str.append("\(spaces(34))            <real>\(delay)</real>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>curve</key>\n")
        str.append("\(spaces(34))            <integer>22</integer>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>1</integer>\n")
        str.append("\(spaces(34))            <key>time</key>\n")
        str.append("\(spaces(34))            <real>\(attack)</real>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>curve</key>\n")
        str.append("\(spaces(34))            <integer>20</integer>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>2</integer>\n")
        str.append("\(spaces(34))            <key>time</key>\n")
        str.append("\(spaces(34))            <real>\(hold)</real>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>curve</key>\n")
        str.append("\(spaces(34))            <integer>20</integer>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>3</integer>\n")
        str.append("\(spaces(34))            <key>time</key>\n")
        str.append("\(spaces(34))            <real>\(decay)</real>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>level</key>\n")
        str.append("\(spaces(34))            <real>\(sustain)</real>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>4</integer>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>curve</key>\n")
        str.append("\(spaces(34))            <integer>20</integer>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>5</integer>\n")
        str.append("\(spaces(34))            <key>time</key>\n")
        str.append("\(spaces(34))            <real>\(release)</real>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))        <dict>\n")
        str.append("\(spaces(34))            <key>curve</key>\n")
        str.append("\(spaces(34))            <integer>20</integer>\n")
        str.append("\(spaces(34))            <key>stage</key>\n")
        str.append("\(spaces(34))            <integer>6</integer>\n")
        str.append("\(spaces(34))            <key>time</key>\n")
        str.append("\(spaces(34))            <real>0.004999999888241291</real>\n")
        str.append("\(spaces(34))        </dict>\n")
        str.append("\(spaces(34))    </array>\n")
        str.append("\(spaces(34))    <key>enabled</key>\n")
        str.append("\(spaces(34))    <true/>\n")
        str.append("\(spaces(34))</dict>\n")
        return str
    }
    static public func closeEnvelopes() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }
    static public func generateFilter(_ cutoffHz: Double = 20000.0, resonanceDb: Double = 0.0) -> String {
        var str = ""
        str.append("                    <key>Filters</key>\n")
        str.append("                    <dict>\n")
        str.append("                        <key>ID</key>\n")
        str.append("                        <integer>0</integer>\n")
        str.append("                        <key>cutoff</key>\n")
        str.append("                        <real>\(cutoffHz)</real>\n")
        str.append("                        <key>enabled</key>\n")
        str.append("                        <false/>\n")
        str.append("                        <key>resonance</key>\n")
        str.append("                        <real>\(resonanceDb)</real>\n")
        str.append("                        <key>type</key>\n")
        str.append("                        <integer>40</integer>\n")
        str.append("                    </dict>\n")
        return str
    }
    static public func generateID(_ id: Int = 0) -> String {
        var str = ""
        str.append("                    <key>ID</key>\n")
        str.append("                    <integer>\(id)</integer>\n")
        return str
    }
    static public func openLFOs() -> String {
        var str = ""
        str.append("                    <key>LFOs</key>\n")
        str.append("                    <array>\n")
        return str
    }
    static public func generateLFO(_ id: Int = 0, delay: Double = 0.0, rate: Double = 3.0, waveform: Int = 0) -> String {
        //0 = triangle, 29 = reverseSaw, 26 = saw, 28 = square, 25 = sine, 75 = sample/hold, 76 = randomInterpolated
        var str = ""
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>\(id)</integer>\n")
        str.append("                            <key>delay</key>\n")
        str.append("                            <real>\(delay)</real>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>rate</key>\n")
        str.append("                            <real>\(rate)</real>\n")
        if waveform != 0 { //if triangle, this section is just not added
            str.append("                            <key>waveform</key>\n")
            str.append("                            <integer>\(waveform)</integer>\n")
        }
        str.append("                        </dict>\n")
        return str
    }
    static public func closeLFOs() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }
    static public func generateOscillator() -> String {
        var str = ""
        str.append("                    <key>Oscillator</key>\n")
        str.append("                    <dict>\n")
        str.append("                        <key>ID</key>\n")
        str.append("                        <integer>0</integer>\n")
        str.append("                        <key>enabled</key>\n")
        str.append("                        <true/>\n")
        str.append("                    </dict>\n")
        return str
    }
    static public func openZones() -> String {
        var str = ""
        str.append("                    <key>Zones</key>\n")
        str.append("                    <array>\n")
        return str
    }
    static public func generateZone(_ id: Int, rootNote: Int, startNote: Int, endNote: Int, wavRef: Int = 268435457, offset: Int = 0, loopEnabled:Bool = false) -> String {
        let wavRefNum = wavRef+offset
        var str = ""
        str.append("                    <dict>\n")
        str.append("                        <key>ID</key>\n")
        str.append("                        <integer>\(id)</integer>\n")
        str.append("                        <key>enabled</key>\n")
        str.append("                        <true/>\n")
        str.append("                        <key>loop enabled</key>\n")
        str.append("                        <\((loopEnabled ? "true" : "false"))/>\n")
        str.append("                        <key>max key</key>\n")
        str.append("                        <integer>\(endNote)</integer>\n")
        str.append("                        <key>min key</key>\n")
        str.append("                        <integer>\(startNote)</integer>\n")
        str.append("                        <key>root key</key>\n")
        str.append("                        <integer>\(rootNote)</integer>\n")
        str.append("                        <key>waveform</key>\n")
        str.append("                        <integer>\(wavRefNum)</integer>\n")
        str.append("                     </dict>\n")
        return str
    }
    static public func closeZones() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }
    static public func layerIgnoreNoteOff(_ ignore: Bool = false) -> String {
        var str = ""
        if ignore{
            str.append("        <key>trigger mode</key>\n")
            str.append("        <integer>11</integer>\n")
        }
        return str
    }
    static public func layerSetVoiceCount(_ count: Int = 16) -> String {
        var str = ""
        str.append("        <key>voice count</key>\n")
        str.append("        <integer>\(count)</integer>\n")
        return str
    }
    static public func closeLayer() -> String {
        var str = ""
        str.append("                </dict>\n")
        return str
    }
    static public func closeLayers() -> String {
        var str: String = ""
        str.append("            </array>\n")
        return str
    }
    static public func closeInstrument(_ name: String = "Code Generated Instrument") -> String {
        var str: String = ""
        str.append("            <key>name</key>\n")
        str.append("            <string>\(name)</string>\n")
        str.append("        </dict>\n")
        return str
    }
    static public func genCoarseTune(_ tune: Int = 0) -> String {
        var str: String = ""
        str.append("        <key>coarse tune</key>\n")
        str.append("        <integer>\(tune)</integer>\n")
        return str
    }
    static public func genDataBlob() -> String {
        var str: String = ""
        str.append("        <key>data</key>\n")
        str.append("        <data>\n")
        str.append("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        str.append("        </data>\n")
        return str
    }
    static public func openFileRefs() -> String {
        var str: String = ""
        str.append("        <key>file-references</key>\n")
        str.append("        <dict>\n")
        return str
    }
    static public func generateFileRef(_ wavRef: Int = 268435457, samplePath: String) -> String {
        var str: String = ""
        str.append("            <key>Sample:\(wavRef)</key>\n")
        str.append("            <string>\(samplePath)</string>\n")
        return str
    }
    static public func closeFileRefs() -> String {
        var str: String = ""
        str.append("        </dict>\n")
        return str
    }
    static public func generateFineTune(_ tune: Double = 0.0) -> String {
        var str: String = ""
        str.append("        <key>fine tune</key>\n")
        str.append("        <real>\(tune)</real>\n")
        return str
    }
    static public func generateGain(_ gain: Double = 0.0) -> String {
        var str: String = ""
        str.append("        <key>gain</key>\n")
        str.append("        <real>\(gain)</real>\n")
        return str
    }
    static public func generateManufacturer(_ manufacturer: Int = 1634758764) -> String {
        var str: String = ""
        str.append("        <key>manufacturer</key>\n")
        str.append("        <integer>\(manufacturer)</integer>\n")
        return str
    }
    static public func generateInstrumentName(_ name: String = "Coded Instrument Name") -> String {
        var str: String = ""
        str.append("        <key>name</key>\n")
        str.append("        <string>\(name)</string>\n")
        return str
    }
    static public func generateOutput(_ output: Int = 0) -> String {
        var str: String = ""
        str.append("        <key>output</key>\n")
        str.append("        <integer>\(output)</integer>\n")
        return str
    }
    static public func generatePan(_ pan: Double = 0.0) -> String {
        var str: String = ""
        str.append("        <key>pan</key>\n")
        str.append("        <real>\(pan)</real>\n")
        return str
    }
    static public func generateTypeAndSubType() -> String {
        var str: String = ""
        str.append("        <key>subtype</key>\n")
        str.append("        <integer>1935764848</integer>\n")
        str.append("        <key>type</key>\n")
        str.append("        <integer>1635085685</integer>\n")
        str.append("        <key>version</key>\n")
        str.append("        <integer>0</integer>\n")
        return str
    }
    static public func generateVoiceCount(_ count: Int = 16) -> String {
        var str: String = ""
        str.append("        <key>voice count</key>\n")
        str.append("        <integer>\(count)</integer>\n")
        return str
    }
    static public func closePreset() -> String {
        var str: String = ""
        str.append("    </dict>\n")
        str.append("</plist>\n")
        return str
    }
    
    static public func generateLayer(_ connections: String, envelopes: String = "", filter: String = "", lfos: String = "", zones: String = "", layer: Int = 0, numVoices: Int = 16, ignoreNoteOff: Bool = false) -> String {
        var str = ""
        str.append(openLayer())
        str.append(openConnections())
        str.append((connections == "" ? generateMinimalConnections(layer) : connections))
        str.append(closeConnections())
        str.append(openEnvelopes())
        str.append((envelopes == "" ? generateEnvelope() : envelopes))
        str.append(closeEnvelopes())
        str.append((filter == "" ? generateFilter() : filter))
        str.append(generateID(layer))
        str.append(openLFOs())
        str.append((lfos == "" ? generateLFO() : lfos))
        str.append(closeLFOs())
        str.append(generateOscillator())
        str.append(openZones())
        str.append(zones)
        str.append(closeZones())
        str.append(layerIgnoreNoteOff(ignoreNoteOff))
        str.append(layerSetVoiceCount(numVoices))
        str.append(closeLayer())
        return str
    }
    static public func generateLayers(_ connections: [String], envelopes: [String], filters: [String], lfos: [String], zones: [String]) -> String {
        //make sure all arrays are same size
        var str = ""
        for i in 0..<connections.count {
            str.append(AKAUPresetBuilder.generateLayer(connections[i], envelopes: envelopes[i], filter: filters[i], lfos: lfos[i], zones: zones[i], layer: i))
        }
        return str
    }
    static public func generateMinimalConnections(_ layer: Int = 0) -> String {
        let layerOffset: Int = 256*layer
        let pitchDest: Int = 816840704+layerOffset
        let envelopeSource: Int = 536870912+layerOffset
        let gainDest: Int = 1343225856+layerOffset
        var str = ""
        str.append(generateConnectionDict(0, source: 300, destination: pitchDest, scale: 12800, transform: 1, invert: false)) //keynum->pitch
        str.append(generateConnectionDict(1, source: envelopeSource, destination: gainDest, scale: -96, transform: 1, invert: true)) //envelope->amp
        str.append(generateConnectionDict(2, source: 301, destination: gainDest, scale: -96, transform: 2, invert: true))
        return str
    }
    static public func genDefaultConnections() -> String {
        var str = ""
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>12800</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>300</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>301</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>7</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>4</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1344274432</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>0.50800001621246338</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-0.50800001621246338</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>10</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>7</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>241</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>12800</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-12800</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>224</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>8</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>100</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-100</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>242</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>6</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>50</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-50</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>268435456</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>5</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>536870912</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        return str
    }
    
    static func genFULLXML() -> String {
        var str: String
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        str.append("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        str.append("<plist version=\"1.0\">\n")
        str.append("    <dict>\n")
        str.append("        <key>AU version</key>\n")
        str.append("        <real>1</real>\n")
        str.append("        <key>Instrument</key>\n")
        str.append("        <dict>\n")
        str.append("            <key>Layers</key>\n")
        str.append("            <array>\n")
        str.append("                <dict>\n")
        str.append("                    <key>Amplifier</key>\n")
        str.append("                    <dict>\n")
        str.append("                        <key>ID</key>\n")
        str.append("                        <integer>0</integer>\n")
        str.append("                        <key>enabled</key>\n")
        str.append("                        <true/>\n")
        str.append("                    </dict>\n")
        str.append("                    <key>Connections</key>\n")
        str.append("                    <array>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>12800</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>300</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>301</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>7</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>3</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>11</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>2</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>4</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1344274432</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>0.50800001621246338</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-0.50800001621246338</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>10</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>7</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>241</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>12800</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-12800</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>224</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>8</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>100</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-100</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>242</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>6</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>816840704</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <false/>\n")
        str.append("                            <key>max value</key>\n")
        str.append("                            <real>50</real>\n")
        str.append("                            <key>min value</key>\n")
        str.append("                            <real>-50</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>268435456</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>5</integer>\n")
        str.append("                            <key>control</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>destination</key>\n")
        str.append("                            <integer>1343225856</integer>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>inverse</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>scale</key>\n")
        str.append("                            <real>-96</real>\n")
        str.append("                            <key>source</key>\n")
        str.append("                            <integer>536870912</integer>\n")
        str.append("                            <key>transform</key>\n")
        str.append("                            <integer>1</integer>\n")
        str.append("                        </dict>\n")
        str.append("                    </array>\n")
        str.append("                    <key>Envelopes</key>\n")
        str.append("                    <array>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>Stages</key>\n")
        str.append("                            <array>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>curve</key>\n")
        str.append("                                    <integer>20</integer>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>0</integer>\n")
        str.append("                                    <key>time</key>\n")
        str.append("                                    <real>0.0</real>\n")
        str.append("                                </dict>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>curve</key>\n")
        str.append("                                    <integer>22</integer>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>1</integer>\n")
        str.append("                                    <key>time</key>\n")
        str.append("                                    <real>***ATTACK***</real>\n")
        str.append("                                </dict>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>curve</key>\n")
        str.append("                                    <integer>20</integer>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>2</integer>\n")
        str.append("                                    <key>time</key>\n")
        str.append("                                    <real>0.0</real>\n")
        str.append("                                </dict>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>curve</key>\n")
        str.append("                                    <integer>20</integer>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>3</integer>\n")
        str.append("                                    <key>time</key>\n")
        str.append("                                    <real>0.0</real>\n")
        str.append("                                </dict>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>level</key>\n")
        str.append("                                    <real>1</real>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>4</integer>\n")
        str.append("                                </dict>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>curve</key>\n")
        str.append("                                    <integer>20</integer>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>5</integer>\n")
        str.append("                                    <key>time</key>\n")
        str.append("                                    <real>***RELEASE***</real>\n")
        str.append("                                </dict>\n")
        str.append("                                <dict>\n")
        str.append("                                    <key>curve</key>\n")
        str.append("                                    <integer>20</integer>\n")
        str.append("                                    <key>stage</key>\n")
        str.append("                                    <integer>6</integer>\n")
        str.append("                                    <key>time</key>\n")
        str.append("                                    <real>0.004999999888241291</real>\n")
        str.append("                                </dict>\n")
        str.append("                            </array>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                        </dict>\n")
        str.append("                    </array>\n")
        str.append("                    <key>Filters</key>\n")
        str.append("                    <dict>\n")
        str.append("                        <key>ID</key>\n")
        str.append("                        <integer>0</integer>\n")
        str.append("                        <key>cutoff</key>\n")
        str.append("                        <real>20000</real>\n")
        str.append("                        <key>enabled</key>\n")
        str.append("                        <false/>\n")
        str.append("                        <key>resonance</key>\n")
        str.append("                        <real>0.0</real>\n")
        str.append("                        <key>type</key>\n")
        str.append("                        <integer>40</integer>\n")
        str.append("                    </dict>\n")
        str.append("                    <key>ID</key>\n")
        str.append("                    <integer>0</integer>\n")
        str.append("                    <key>LFOs</key>\n")
        str.append("                    <array>\n")
        str.append("                        <dict>\n")
        str.append("                            <key>ID</key>\n")
        str.append("                            <integer>0</integer>\n")
        str.append("                            <key>delay</key>\n")
        str.append("                            <real>0.069456316530704498</real>\n")
        str.append("                            <key>enabled</key>\n")
        str.append("                            <true/>\n")
        str.append("                            <key>rate</key>\n")
        str.append("                            <real>10.117301940917969</real>\n")
        str.append("                            <key>waveform</key>\n")
        str.append("                            <integer>25</integer>\n")
        str.append("                        </dict>\n")
        str.append("                    </array>\n")
        str.append("                    <key>Oscillator</key>\n")
        str.append("                    <dict>\n")
        str.append("                        <key>ID</key>\n")
        str.append("                        <integer>0</integer>\n")
        str.append("                        <key>enabled</key>\n")
        str.append("                        <true/>\n")
        str.append("                    </dict>\n")
        str.append("                    <key>Zones</key>\n")
        str.append("                    <array>\n")
        str.append("                        ***ZONEMAPPINGS***\n")
        str.append("                    </array>\n")
        str.append("                </dict>\n")
        str.append("            </array>\n")
        str.append("            <key>name</key>\n")
        str.append("            <string>Default Instrument</string>\n")
        str.append("        </dict>\n")
        str.append("        <key>coarse tune</key>\n")
        str.append("        <integer>0</integer>\n")
        str.append("        <key>data</key>\n")
        str.append("        <data>\n")
        str.append("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        str.append("        </data>\n")
        str.append("        <key>file-references</key>\n")
        str.append("        <dict>\n")
        str.append("            ***SAMPLEFILES***\n")
        str.append("        </dict>\n")
        str.append("        <key>fine tune</key>\n")
        str.append("        <real>0.0</real>\n")
        str.append("        <key>gain</key>\n")
        str.append("        <real>0.0</real>\n")
        str.append("        <key>manufacturer</key>\n")
        str.append("        <integer>1634758764</integer>\n")
        str.append("        <key>name</key>\n")
        str.append("        <string>***INSTNAME***</string>\n")
        str.append("        <key>output</key>\n")
        str.append("        <integer>0</integer>\n")
        str.append("        <key>pan</key>\n")
        str.append("        <real>0.0</real>\n")
        str.append("        <key>subtype</key>\n")
        str.append("        <integer>1935764848</integer>\n")
        str.append("        <key>type</key>\n")
        str.append("        <integer>1635085685</integer>\n")
        str.append("        <key>version</key>\n")
        str.append("        <integer>0</integer>\n")
        str.append("        <key>voice count</key>\n")
        str.append("        <integer>64</integer>\n")
        str.append("    </dict>\n")
        str.append("</plist>\n")
        return str
    }
    
}
/*
 making notes of parameters as I reverse engineer them...
 to access a the next layer, add 256
 destinations:
 1343225856 = amp gain
 818937856 = samplestart factor
 
 816840704 = layer1pitch
 816840960 = layer2pitch (+256)
 816841216 = layer3pitch (+256)
 
 1343225856 = layer1gain
 1343226112 = layer2gain (+256)
 1343226368 = layer3gain (+256)
 
 sources:
 300 = keynumber
 301 = keyvelocity
 536870912 = layer1envelope
 536871168 = layer2envelope (+256)536871424
 268435456 = layer1LFO1
 268435457 = layer1LFO2
 
 */
