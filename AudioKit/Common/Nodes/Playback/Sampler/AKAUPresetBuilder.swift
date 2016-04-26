//
//  AUPresetTemplate.swift
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
    static public func createAUPresetFromDict(dict: NSDictionary,
                                              path: String,
                                              instrumentName: String,
                                              attack: Double? = 0,
                                              release: Double? = 0) {
        let rootNoteKey = "rootnote"
        let startNoteKey = "startnote"
        let endNoteKey = "endnote"
        let filenameKey = "filename"
        let triggerModeKey = "triggerMode"
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
                let alreadyLoadedSound: String = loadedSoundDict.objectForKey(filenameKey) as! String
                let newLoadingSound: String = soundDict.objectForKey(filenameKey) as! String
                if alreadyLoadedSound == newLoadingSound {
                    alreadyLoaded = true
                    sampleNum = loadedSoundDict.objectForKey("sampleNum") as! Int
                }
            }
            
            if sound.objectForKey(startNoteKey) == nil || sound.objectForKey(endNoteKey) == nil {
                soundDict.setObject(sound.objectForKey(rootNoteKey)!, forKey: startNoteKey)
                soundDict.setObject(sound.objectForKey(rootNoteKey)!, forKey: endNoteKey)
            }
            if sound.objectForKey(rootNoteKey) == nil {
                //error
            } else {
                soundDict.setObject(sound.objectForKey(rootNoteKey)!, forKey: rootNoteKey)
            }
            
            if !alreadyLoaded { //if this is a new sound, then add it to samplefile xml
                sampleNum = sampleNumStart + sampleIteration
                let idXML = AKAUPresetBuilder.generateFileRef(sampleNum, samplePath: sound.objectForKey("filename")! as! String)
                sampleIDXML.appendContentsOf(idXML)
                
                sampleIteration += 1
            }
            
            let startNote = soundDict.objectForKey(startNoteKey)! as! Int
            let endNote = soundDict.objectForKey(endNoteKey)! as! Int
            let rootNote = soundDict.objectForKey(rootNoteKey)! as! Int
            let tempSampleZoneXML: String = AKAUPresetBuilder.generateZone(i, rootNote: rootNote, startNote: startNote, endNote: endNote, wavRef: sampleNum)
            
            sampleZoneXML.appendContentsOf(tempSampleZoneXML)
            soundDict.setObject(sampleNum, forKey: "sampleNum")
            loadSoundsArr.append(soundDict)
        }//end sounds
        
        let envelopesXML = AKAUPresetBuilder.generateEnvelope(0, delay: 0, attack: attack!, hold: 0, decay: 0, sustain: 1, release: release!)
        let str = AKAUPresetBuilder.buildInstrument(instrumentName, envelopes: envelopesXML, zones: sampleZoneXML, filerefs: sampleIDXML)
        
        //write to file
        do {
            print("Writing to \(path)")
            try str.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Could not write to \(path)")
            print(error)
        }
    }//end func createAUPresetFromDict
    
    /// This functions returns 1 dictionary entry for a particular sample zone. You then add this to an array, and feed that into createAUPresetFromDict
    /// - parameter rootNote:  Note at which the sample playback is unchanged
    /// - parameter filename:  Name of the file
    /// - parameter startNote: First note in range
    /// - parameter endNote:   Last note in range
    ///
    public static func generateDictionary(
        rootNote: Int,
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
    
    static func spaces(count: Int) -> String {
        return String(count: count, repeatedValue: (" " as Character))
    }
    
    static public func buildInstrument(name: String = "Coded Instrument Name",
                                       connections: String = "",
                                       envelopes: String = "",
                                       filter: String = "",
                                       lfos: String = "",
                                       zones: String = "***ZONES***\n",
                                       filerefs: String = "***FILEREFS***\n",
                                       layers: String = "") -> String {
        var presetXML = openPreset()
        presetXML.appendContentsOf(openInstrument())
        presetXML.appendContentsOf(openLayers())
        
        if layers == "" {
            presetXML.appendContentsOf(openLayer())
            presetXML.appendContentsOf(openConnections())
            presetXML.appendContentsOf((connections == "" ? genDefaultConnections() : connections))
            presetXML.appendContentsOf(closeConnections())
            presetXML.appendContentsOf(openEnvelopes())
            presetXML.appendContentsOf((envelopes == "" ? generateEnvelope() : envelopes))
            presetXML.appendContentsOf(closeEnvelopes())
            presetXML.appendContentsOf((filter == "" ? generateFilter() : filter))
            presetXML.appendContentsOf(generateID())
            presetXML.appendContentsOf(openLFOs())
            presetXML.appendContentsOf((lfos == "" ? generateLFO() : lfos))
            presetXML.appendContentsOf(closeLFOs())
            presetXML.appendContentsOf(generateOscillator())
            presetXML.appendContentsOf(openZones())
            presetXML.appendContentsOf(zones)
            //presetXML.appendContentsOf(generateZone(<#T##id: Int##Int#>, rootNote: <#T##Int#>, startNote: <#T##Int#>, endNote: <#T##Int#>, wavRef: <#T##Int#>))
            presetXML.appendContentsOf(closeZones())
            presetXML.appendContentsOf(closeLayer())
        } else {
            presetXML.appendContentsOf(layers)
        }//end if layers provided
        
        presetXML.appendContentsOf(closeLayers())
        presetXML.appendContentsOf(closeInstrument())
        presetXML.appendContentsOf(genCoarseTune())
        presetXML.appendContentsOf(genDataBlob())
        presetXML.appendContentsOf(openFileRefs())
        presetXML.appendContentsOf(filerefs)
        //presetXML.appendContentsOf(generateFileRef(<#T##wavRef: Int##Int#>, samplePath: <#T##String#>))
        presetXML.appendContentsOf(closeFileRefs())
        presetXML.appendContentsOf(generateFineTune())
        presetXML.appendContentsOf(generateGain())
        presetXML.appendContentsOf(generateManufacturer())
        presetXML.appendContentsOf(generateInstrumentName(name))
        presetXML.appendContentsOf(generateOutput())
        presetXML.appendContentsOf(generatePan())
        presetXML.appendContentsOf(generateTypeAndSubType())
        presetXML.appendContentsOf(generateVoiceCount())
        presetXML.appendContentsOf(closePreset())
        return presetXML
    }
    static public func openPreset() -> String {
        var str: String = ""
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        str.appendContentsOf("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        str.appendContentsOf("<plist version=\"1.0\">\n")
        str.appendContentsOf("    <dict>\n")
        str.appendContentsOf("        <key>AU version</key>\n")
        str.appendContentsOf("        <real>1</real>\n")
        return str
    }
    static public func openInstrument() -> String {
        var str: String = ""
        str.appendContentsOf("        <key>Instrument</key>\n")
        str.appendContentsOf("        <dict>\n")
        return str
    }
    static public func openLayers() -> String {
        var str: String = ""
        str.appendContentsOf("            <key>Layers</key>\n")
        str.appendContentsOf("            <array>\n")
        return str
    }

    static public func openLayer() -> String {
        var str = ""
        str.appendContentsOf("\(spaces(16))<dict>\n")
        str.appendContentsOf("\(spaces(16))    <key>Amplifier</key>\n")
        str.appendContentsOf("\(spaces(16))    <dict>\n")
        str.appendContentsOf("\(spaces(16))        <key>ID</key>\n")
        str.appendContentsOf("\(spaces(16))        <integer>0</integer>\n")
        str.appendContentsOf("\(spaces(16))        <key>enabled</key>\n")
        str.appendContentsOf("\(spaces(16))        <true/>\n")
        str.appendContentsOf("\(spaces(16))    </dict>\n")
        return str
    }
    static public func openConnections() -> String {
        var str = ""
        str.appendContentsOf("                    <key>Connections</key>\n")
        str.appendContentsOf("                    <array>\n")
        return str
    }
    static public func generateConnectionDict(id: Int,
                                              source: Int,
                                              destination: Int,
                                              scale: Int,
                                              transform: Int = 1,
                                              invert: Bool = false) -> String {
        var str = ""
        str.appendContentsOf("\(spaces(34))<dict>\n")
        str.appendContentsOf("\(spaces(34))    <key>ID</key>\n")
        str.appendContentsOf("\(spaces(34))    <integer>\(id)</integer>\n")
        str.appendContentsOf("\(spaces(34))    <key>control</key>\n")
        str.appendContentsOf("\(spaces(34))    <integer>0</integer>\n")
        str.appendContentsOf("\(spaces(34))    <key>destination</key>\n")
        str.appendContentsOf("\(spaces(34))    <integer>\(destination)</integer>\n")
        str.appendContentsOf("\(spaces(34))    <key>enabled</key>\n")
        str.appendContentsOf("\(spaces(34))    <true/>\n")
        str.appendContentsOf("\(spaces(34))    <key>inverse</key>\n")
        str.appendContentsOf("\(spaces(34))    <\((invert ? "true" : "false"))/>\n")
        str.appendContentsOf("\(spaces(34))    <key>scale</key>\n")
        str.appendContentsOf("\(spaces(34))    <real>\(scale)</real>\n")
        str.appendContentsOf("\(spaces(34))    <key>source</key>\n")
        str.appendContentsOf("\(spaces(34))    <integer>\(source)</integer>\n")
        str.appendContentsOf("\(spaces(34))    <key>transform</key>\n")
        str.appendContentsOf("\(spaces(34))    <integer>1</integer>\n")
        str.appendContentsOf("\(spaces(34))</dict>\n")
        return str
    }
    static public func closeConnections() -> String {
        var str = ""
        str.appendContentsOf("                    </array>\n")
        return str
    }
    static public func openEnvelopes() -> String {
        var str = ""
        str.appendContentsOf("                    <key>Envelopes</key>\n")
        str.appendContentsOf("                    <array>\n")
        return str
    }
    static public func generateEnvelope(id: Int = 0,
                                        delay: Double = 0.0,
                                        attack: Double = 0.0,
                                        hold: Double = 0.0,
                                        decay: Double = 0.0,
                                        sustain: Double = 1.0,
                                        release: Double = 0.0) -> String {
        var str = ""
        str.appendContentsOf("\(spaces(34))<dict>\n")
        str.appendContentsOf("\(spaces(34))    <key>ID</key>\n")
        str.appendContentsOf("\(spaces(34))    <integer>\(id)</integer>\n")
        str.appendContentsOf("\(spaces(34))    <key>Stages</key>\n")
        str.appendContentsOf("\(spaces(34))    <array>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>curve</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>20</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>0</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>time</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>\(delay)</real>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>curve</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>22</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>1</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>time</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>\(attack)</real>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>curve</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>20</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>2</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>time</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>\(hold)</real>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>curve</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>20</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>3</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>time</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>\(decay)</real>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>level</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>\(sustain)</real>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>4</integer>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>curve</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>20</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>5</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>time</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>\(release)</real>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))        <dict>\n")
        str.appendContentsOf("\(spaces(34))            <key>curve</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>20</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>stage</key>\n")
        str.appendContentsOf("\(spaces(34))            <integer>6</integer>\n")
        str.appendContentsOf("\(spaces(34))            <key>time</key>\n")
        str.appendContentsOf("\(spaces(34))            <real>0.004999999888241291</real>\n")
        str.appendContentsOf("\(spaces(34))        </dict>\n")
        str.appendContentsOf("\(spaces(34))    </array>\n")
        str.appendContentsOf("\(spaces(34))    <key>enabled</key>\n")
        str.appendContentsOf("\(spaces(34))    <true/>\n")
        str.appendContentsOf("\(spaces(34))</dict>\n")
        return str
    }
    static public func closeEnvelopes() -> String {
        var str = ""
        str.appendContentsOf("                    </array>\n")
        return str
    }
    static public func generateFilter(cutoffHz: Double = 20000.0, resonanceDb: Double = 0.0) -> String {
        var str = ""
        str.appendContentsOf("                    <key>Filters</key>\n")
        str.appendContentsOf("                    <dict>\n")
        str.appendContentsOf("                        <key>ID</key>\n")
        str.appendContentsOf("                        <integer>0</integer>\n")
        str.appendContentsOf("                        <key>cutoff</key>\n")
        str.appendContentsOf("                        <real>\(cutoffHz)</real>\n")
        str.appendContentsOf("                        <key>enabled</key>\n")
        str.appendContentsOf("                        <false/>\n")
        str.appendContentsOf("                        <key>resonance</key>\n")
        str.appendContentsOf("                        <real>\(resonanceDb)</real>\n")
        str.appendContentsOf("                        <key>type</key>\n")
        str.appendContentsOf("                        <integer>40</integer>\n")
        str.appendContentsOf("                    </dict>\n")
        return str
    }
    static public func generateID(id: Int = 0) -> String {
        var str = ""
        str.appendContentsOf("                    <key>ID</key>\n")
        str.appendContentsOf("                    <integer>\(id)</integer>\n")
        return str
    }
    static public func openLFOs() -> String {
        var str = ""
        str.appendContentsOf("                    <key>LFOs</key>\n")
        str.appendContentsOf("                    <array>\n")
        return str
    }
    static public func generateLFO(id: Int = 0, delay: Double = 0.0, rate: Double = 3.0, waveform: Int = 0) -> String {
        //0 = triangle, 29 = reverseSaw, 26 = saw, 28 = square, 25 = sine, 75 = sample/hold, 76 = randomInterpolated
        var str = ""
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>\(id)</integer>\n")
        str.appendContentsOf("                            <key>delay</key>\n")
        str.appendContentsOf("                            <real>\(delay)</real>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>rate</key>\n")
        str.appendContentsOf("                            <real>\(rate)</real>\n")
        if waveform != 0 { //if triangle, this section is just not added
            str.appendContentsOf("                            <key>waveform</key>\n")
            str.appendContentsOf("                            <integer>\(waveform)</integer>\n")
        }
        str.appendContentsOf("                        </dict>\n")
        return str
    }
    static public func closeLFOs() -> String {
        var str = ""
        str.appendContentsOf("                    </array>\n")
        return str
    }
    static public func generateOscillator() -> String {
        var str = ""
        str.appendContentsOf("                    <key>Oscillator</key>\n")
        str.appendContentsOf("                    <dict>\n")
        str.appendContentsOf("                        <key>ID</key>\n")
        str.appendContentsOf("                        <integer>0</integer>\n")
        str.appendContentsOf("                        <key>enabled</key>\n")
        str.appendContentsOf("                        <true/>\n")
        str.appendContentsOf("                    </dict>\n")
        return str
    }
    static public func openZones() -> String {
        var str = ""
        str.appendContentsOf("                    <key>Zones</key>\n")
        str.appendContentsOf("                    <array>\n")
        return str
    }
    static public func generateZone(id: Int, rootNote: Int, startNote: Int, endNote: Int, wavRef: Int = 268435457, offset: Int = 0, loopEnabled:Bool = false) -> String {
        let wavRefNum = wavRef+offset
        var str = ""
        str.appendContentsOf("                    <dict>\n")
        str.appendContentsOf("                        <key>ID</key>\n")
        str.appendContentsOf("                        <integer>\(id)</integer>\n")
        str.appendContentsOf("                        <key>enabled</key>\n")
        str.appendContentsOf("                        <true/>\n")
        str.appendContentsOf("                        <key>loop enabled</key>\n")
        str.appendContentsOf("                        <\((loopEnabled ? "true" : "false"))/>\n")
        str.appendContentsOf("                        <key>max key</key>\n")
        str.appendContentsOf("                        <integer>\(endNote)</integer>\n")
        str.appendContentsOf("                        <key>min key</key>\n")
        str.appendContentsOf("                        <integer>\(startNote)</integer>\n")
        str.appendContentsOf("                        <key>root key</key>\n")
        str.appendContentsOf("                        <integer>\(rootNote)</integer>\n")
        str.appendContentsOf("                        <key>waveform</key>\n")
        str.appendContentsOf("                        <integer>\(wavRefNum)</integer>\n")
        str.appendContentsOf("                     </dict>\n")
        return str
    }
    static public func closeZones() -> String {
        var str = ""
        str.appendContentsOf("                    </array>\n")
        return str
    }
    static public func layerIgnoreNoteOff(ignore: Bool = false) -> String {
        var str = ""
        if ignore{
            str.appendContentsOf("        <key>trigger mode</key>\n")
            str.appendContentsOf("        <integer>11</integer>\n")
        }
        return str
    }
    static public func layerSetVoiceCount(count: Int = 16) -> String {
        var str = ""
        str.appendContentsOf("        <key>voice count</key>\n")
        str.appendContentsOf("        <integer>\(count)</integer>\n")
        return str
    }
    static public func closeLayer() -> String {
        var str = ""
        str.appendContentsOf("                </dict>\n")
        return str
    }
    static public func closeLayers() -> String {
        var str: String = ""
        str.appendContentsOf("            </array>\n")
        return str
    }
    static public func closeInstrument(name: String = "Code Generated Instrument") -> String {
        var str: String = ""
        str.appendContentsOf("            <key>name</key>\n")
        str.appendContentsOf("            <string>\(name)</string>\n")
        str.appendContentsOf("        </dict>\n")
        return str
    }
    static public func genCoarseTune(tune: Int = 0) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>coarse tune</key>\n")
        str.appendContentsOf("        <integer>\(tune)</integer>\n")
        return str
    }
    static public func genDataBlob() -> String {
        var str: String = ""
        str.appendContentsOf("        <key>data</key>\n")
        str.appendContentsOf("        <data>\n")
        str.appendContentsOf("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        str.appendContentsOf("        </data>\n")
        return str
    }
    static public func openFileRefs() -> String {
        var str: String = ""
        str.appendContentsOf("        <key>file-references</key>\n")
        str.appendContentsOf("        <dict>\n")
        return str
    }
    static public func generateFileRef(wavRef: Int = 268435457, samplePath: String) -> String {
        var str: String = ""
        str.appendContentsOf("            <key>Sample:\(wavRef)</key>\n")
        str.appendContentsOf("            <string>\(samplePath)</string>\n")
        return str
    }
    static public func closeFileRefs() -> String {
        var str: String = ""
        str.appendContentsOf("        </dict>\n")
        return str
    }
    static public func generateFineTune(tune: Double = 0.0) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>fine tune</key>\n")
        str.appendContentsOf("        <real>\(tune)</real>\n")
        return str
    }
    static public func generateGain(gain: Double = 0.0) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>gain</key>\n")
        str.appendContentsOf("        <real>\(gain)</real>\n")
        return str
    }
    static public func generateManufacturer(manufacturer: Int = 1634758764) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>manufacturer</key>\n")
        str.appendContentsOf("        <integer>\(manufacturer)</integer>\n")
        return str
    }
    static public func generateInstrumentName(name: String = "Coded Instrument Name") -> String {
        var str: String = ""
        str.appendContentsOf("        <key>name</key>\n")
        str.appendContentsOf("        <string>\(name)</string>\n")
        return str
    }
    static public func generateOutput(output: Int = 0) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>output</key>\n")
        str.appendContentsOf("        <integer>\(output)</integer>\n")
        return str
    }
    static public func generatePan(pan: Double = 0.0) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>pan</key>\n")
        str.appendContentsOf("        <real>\(pan)</real>\n")
        return str
    }
    static public func generateTypeAndSubType() -> String {
        var str: String = ""
        str.appendContentsOf("        <key>subtype</key>\n")
        str.appendContentsOf("        <integer>1935764848</integer>\n")
        str.appendContentsOf("        <key>type</key>\n")
        str.appendContentsOf("        <integer>1635085685</integer>\n")
        str.appendContentsOf("        <key>version</key>\n")
        str.appendContentsOf("        <integer>0</integer>\n")
        return str
    }
    static public func generateVoiceCount(count: Int = 16) -> String {
        var str: String = ""
        str.appendContentsOf("        <key>voice count</key>\n")
        str.appendContentsOf("        <integer>\(count)</integer>\n")
        return str
    }
    static public func closePreset() -> String {
        var str: String = ""
        str.appendContentsOf("    </dict>\n")
        str.appendContentsOf("</plist>\n")
        return str
    }
    
    static public func generateLayer(connections: String, envelopes: String = "", filter: String = "", lfos: String = "", zones: String = "", layer: Int = 0, numVoices: Int = 16, ignoreNoteOff: Bool = false) -> String {
        var str = ""
        str.appendContentsOf(openLayer())
        str.appendContentsOf(openConnections())
        str.appendContentsOf((connections == "" ? generateMinimalConnections(layer) : connections))
        str.appendContentsOf(closeConnections())
        str.appendContentsOf(openEnvelopes())
        str.appendContentsOf((envelopes == "" ? generateEnvelope() : envelopes))
        str.appendContentsOf(closeEnvelopes())
        str.appendContentsOf((filter == "" ? generateFilter() : filter))
        str.appendContentsOf(generateID(layer))
        str.appendContentsOf(openLFOs())
        str.appendContentsOf((lfos == "" ? generateLFO() : lfos))
        str.appendContentsOf(closeLFOs())
        str.appendContentsOf(generateOscillator())
        str.appendContentsOf(openZones())
        str.appendContentsOf(zones)
        str.appendContentsOf(closeZones())
        str.appendContentsOf(layerIgnoreNoteOff(ignoreNoteOff))
        str.appendContentsOf(layerSetVoiceCount(numVoices))
        str.appendContentsOf(closeLayer())
        return str
    }
    static public func generateLayers(connections: [String], envelopes: [String], filters: [String], lfos: [String], zones: [String]) -> String {
        //make sure all arrays are same size
        var str = ""
        for i in 0..<connections.count {
            str.appendContentsOf(AKAUPresetBuilder.generateLayer(connections[i], envelopes: envelopes[i], filter: filters[i], lfos: lfos[i], zones: zones[i], layer: i))
        }
        return str
    }
    static public func generateMinimalConnections(layer: Int = 0) -> String {
        let layerOffset: Int = 256*layer
        let pitchDest: Int = 816840704+layerOffset
        let envelopeSource: Int = 536870912+layerOffset
        let gainDest: Int = 1343225856+layerOffset
        var str = ""
        str.appendContentsOf(generateConnectionDict(0, source: 300, destination: pitchDest, scale: 12800, transform: 1, invert: false)) //keynum->pitch
        str.appendContentsOf(generateConnectionDict(1, source: envelopeSource, destination: gainDest, scale: -96, transform: 1, invert: true)) //envelope->amp
        str.appendContentsOf(generateConnectionDict(2, source: 301, destination: gainDest, scale: -96, transform: 2, invert: true))
        return str
    }
    static public func genDefaultConnections() -> String {
        var str = ""
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>12800</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>300</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>301</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>7</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>4</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1344274432</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>0.50800001621246338</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-0.50800001621246338</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>10</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>7</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>241</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>12800</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-12800</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>224</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>8</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>100</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-100</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>242</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>6</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>50</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-50</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>268435456</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>5</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>536870912</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        return str
    }
    
    static func genFULLXML() -> String {
        var str: String
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        str.appendContentsOf("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        str.appendContentsOf("<plist version=\"1.0\">\n")
        str.appendContentsOf("    <dict>\n")
        str.appendContentsOf("        <key>AU version</key>\n")
        str.appendContentsOf("        <real>1</real>\n")
        str.appendContentsOf("        <key>Instrument</key>\n")
        str.appendContentsOf("        <dict>\n")
        str.appendContentsOf("            <key>Layers</key>\n")
        str.appendContentsOf("            <array>\n")
        str.appendContentsOf("                <dict>\n")
        str.appendContentsOf("                    <key>Amplifier</key>\n")
        str.appendContentsOf("                    <dict>\n")
        str.appendContentsOf("                        <key>ID</key>\n")
        str.appendContentsOf("                        <integer>0</integer>\n")
        str.appendContentsOf("                        <key>enabled</key>\n")
        str.appendContentsOf("                        <true/>\n")
        str.appendContentsOf("                    </dict>\n")
        str.appendContentsOf("                    <key>Connections</key>\n")
        str.appendContentsOf("                    <array>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>12800</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>300</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>301</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>7</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>3</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>11</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>2</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>4</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1344274432</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>0.50800001621246338</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-0.50800001621246338</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>10</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>7</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>241</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>12800</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-12800</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>224</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>8</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>100</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-100</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>242</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>6</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>816840704</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <false/>\n")
        str.appendContentsOf("                            <key>max value</key>\n")
        str.appendContentsOf("                            <real>50</real>\n")
        str.appendContentsOf("                            <key>min value</key>\n")
        str.appendContentsOf("                            <real>-50</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>268435456</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>5</integer>\n")
        str.appendContentsOf("                            <key>control</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>destination</key>\n")
        str.appendContentsOf("                            <integer>1343225856</integer>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>inverse</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>scale</key>\n")
        str.appendContentsOf("                            <real>-96</real>\n")
        str.appendContentsOf("                            <key>source</key>\n")
        str.appendContentsOf("                            <integer>536870912</integer>\n")
        str.appendContentsOf("                            <key>transform</key>\n")
        str.appendContentsOf("                            <integer>1</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                    </array>\n")
        str.appendContentsOf("                    <key>Envelopes</key>\n")
        str.appendContentsOf("                    <array>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>Stages</key>\n")
        str.appendContentsOf("                            <array>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>curve</key>\n")
        str.appendContentsOf("                                    <integer>20</integer>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>0</integer>\n")
        str.appendContentsOf("                                    <key>time</key>\n")
        str.appendContentsOf("                                    <real>0.0</real>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>curve</key>\n")
        str.appendContentsOf("                                    <integer>22</integer>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>1</integer>\n")
        str.appendContentsOf("                                    <key>time</key>\n")
        str.appendContentsOf("                                    <real>***ATTACK***</real>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>curve</key>\n")
        str.appendContentsOf("                                    <integer>20</integer>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>2</integer>\n")
        str.appendContentsOf("                                    <key>time</key>\n")
        str.appendContentsOf("                                    <real>0.0</real>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>curve</key>\n")
        str.appendContentsOf("                                    <integer>20</integer>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>3</integer>\n")
        str.appendContentsOf("                                    <key>time</key>\n")
        str.appendContentsOf("                                    <real>0.0</real>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>level</key>\n")
        str.appendContentsOf("                                    <real>1</real>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>4</integer>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>curve</key>\n")
        str.appendContentsOf("                                    <integer>20</integer>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>5</integer>\n")
        str.appendContentsOf("                                    <key>time</key>\n")
        str.appendContentsOf("                                    <real>***RELEASE***</real>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                                <dict>\n")
        str.appendContentsOf("                                    <key>curve</key>\n")
        str.appendContentsOf("                                    <integer>20</integer>\n")
        str.appendContentsOf("                                    <key>stage</key>\n")
        str.appendContentsOf("                                    <integer>6</integer>\n")
        str.appendContentsOf("                                    <key>time</key>\n")
        str.appendContentsOf("                                    <real>0.004999999888241291</real>\n")
        str.appendContentsOf("                                </dict>\n")
        str.appendContentsOf("                            </array>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                    </array>\n")
        str.appendContentsOf("                    <key>Filters</key>\n")
        str.appendContentsOf("                    <dict>\n")
        str.appendContentsOf("                        <key>ID</key>\n")
        str.appendContentsOf("                        <integer>0</integer>\n")
        str.appendContentsOf("                        <key>cutoff</key>\n")
        str.appendContentsOf("                        <real>20000</real>\n")
        str.appendContentsOf("                        <key>enabled</key>\n")
        str.appendContentsOf("                        <false/>\n")
        str.appendContentsOf("                        <key>resonance</key>\n")
        str.appendContentsOf("                        <real>0.0</real>\n")
        str.appendContentsOf("                        <key>type</key>\n")
        str.appendContentsOf("                        <integer>40</integer>\n")
        str.appendContentsOf("                    </dict>\n")
        str.appendContentsOf("                    <key>ID</key>\n")
        str.appendContentsOf("                    <integer>0</integer>\n")
        str.appendContentsOf("                    <key>LFOs</key>\n")
        str.appendContentsOf("                    <array>\n")
        str.appendContentsOf("                        <dict>\n")
        str.appendContentsOf("                            <key>ID</key>\n")
        str.appendContentsOf("                            <integer>0</integer>\n")
        str.appendContentsOf("                            <key>delay</key>\n")
        str.appendContentsOf("                            <real>0.069456316530704498</real>\n")
        str.appendContentsOf("                            <key>enabled</key>\n")
        str.appendContentsOf("                            <true/>\n")
        str.appendContentsOf("                            <key>rate</key>\n")
        str.appendContentsOf("                            <real>10.117301940917969</real>\n")
        str.appendContentsOf("                            <key>waveform</key>\n")
        str.appendContentsOf("                            <integer>25</integer>\n")
        str.appendContentsOf("                        </dict>\n")
        str.appendContentsOf("                    </array>\n")
        str.appendContentsOf("                    <key>Oscillator</key>\n")
        str.appendContentsOf("                    <dict>\n")
        str.appendContentsOf("                        <key>ID</key>\n")
        str.appendContentsOf("                        <integer>0</integer>\n")
        str.appendContentsOf("                        <key>enabled</key>\n")
        str.appendContentsOf("                        <true/>\n")
        str.appendContentsOf("                    </dict>\n")
        str.appendContentsOf("                    <key>Zones</key>\n")
        str.appendContentsOf("                    <array>\n")
        str.appendContentsOf("                        ***ZONEMAPPINGS***\n")
        str.appendContentsOf("                    </array>\n")
        str.appendContentsOf("                </dict>\n")
        str.appendContentsOf("            </array>\n")
        str.appendContentsOf("            <key>name</key>\n")
        str.appendContentsOf("            <string>Default Instrument</string>\n")
        str.appendContentsOf("        </dict>\n")
        str.appendContentsOf("        <key>coarse tune</key>\n")
        str.appendContentsOf("        <integer>0</integer>\n")
        str.appendContentsOf("        <key>data</key>\n")
        str.appendContentsOf("        <data>\n")
        str.appendContentsOf("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        str.appendContentsOf("        </data>\n")
        str.appendContentsOf("        <key>file-references</key>\n")
        str.appendContentsOf("        <dict>\n")
        str.appendContentsOf("            ***SAMPLEFILES***\n")
        str.appendContentsOf("        </dict>\n")
        str.appendContentsOf("        <key>fine tune</key>\n")
        str.appendContentsOf("        <real>0.0</real>\n")
        str.appendContentsOf("        <key>gain</key>\n")
        str.appendContentsOf("        <real>0.0</real>\n")
        str.appendContentsOf("        <key>manufacturer</key>\n")
        str.appendContentsOf("        <integer>1634758764</integer>\n")
        str.appendContentsOf("        <key>name</key>\n")
        str.appendContentsOf("        <string>***INSTNAME***</string>\n")
        str.appendContentsOf("        <key>output</key>\n")
        str.appendContentsOf("        <integer>0</integer>\n")
        str.appendContentsOf("        <key>pan</key>\n")
        str.appendContentsOf("        <real>0.0</real>\n")
        str.appendContentsOf("        <key>subtype</key>\n")
        str.appendContentsOf("        <integer>1935764848</integer>\n")
        str.appendContentsOf("        <key>type</key>\n")
        str.appendContentsOf("        <integer>1635085685</integer>\n")
        str.appendContentsOf("        <key>version</key>\n")
        str.appendContentsOf("        <integer>0</integer>\n")
        str.appendContentsOf("        <key>voice count</key>\n")
        str.appendContentsOf("        <integer>64</integer>\n")
        str.appendContentsOf("    </dict>\n")
        str.appendContentsOf("</plist>\n")
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
