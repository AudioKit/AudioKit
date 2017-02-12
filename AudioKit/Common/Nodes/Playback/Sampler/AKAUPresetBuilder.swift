//
//  AKAUPresetBuilder.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Builds presets for Apple sampler to read from
open class AKAUPresetBuilder {

    fileprivate var presetXML = ""
    fileprivate var layers = [String]()
    fileprivate var connections = [String]()
    fileprivate var envelopes = [String]()
    fileprivate var lfos = [String]()
    fileprivate var zones = [String]()
    fileprivate var fileRefs = [String]()
    fileprivate var filters = [String]()

    /// Create preset with the given components
    ///
    /// - Parameters:
    ///   - name:        Coded instrument name
    ///   - connections: Connection XML
    ///   - envelopes:   Envelopes XML
    ///   - filter:      Filter XML
    ///   - lfos:        Low Frequency Oscillator XML
    ///   - zones:       Zones XML
    ///   - filerefs:    File references XML
    ///
    init(name: String = "Coded Instrument Name",
         connections: String = "***CONNECTIONS***\n",
         envelopes: String = "***ENVELOPES***\n",
         filter: String = "***FILTER***\n",
         lfos: String = "***LFOS***\n",
         zones: String = "***ZONES***\n",
         filerefs: String = "***FILEREFS***\n") {
        presetXML = AKAUPresetBuilder.buildInstrument(name: name,
                                                      connections: connections,
                                                      envelopes: envelopes,
                                                      filter: filter,
                                                      lfos: lfos,
                                                      zones: zones,
                                                      filerefs: filerefs)
    }

    /// Create an AUPreset from a collection of dictionaries.
    /// dict is a collection of other dictionaries that have the format like this:
    ///   - ***Key:Value***
    ///   - filename: string
    ///   - rootnote: int
    ///   - startnote: int (optional)
    ///   - endnote: int (optional)
    ///
    /// - Parameters:
    ///   - dict:           Collection of dictionaries with format as given above
    ///   - path:           Where the AUPreset will be created
    ///   - instrumentName: The name of the AUPreset
    ///   - attack:         Attack time in seconds
    ///   - release:        Release time in seconds
    ///
    static open func createAUPreset(dict: NSDictionary,
                                    path: String,
                                    instrumentName: String,
                                    attack: Double? = 0,
                                    release: Double? = 0) {
        let rootNoteKey = "rootnote"
        let startNoteKey = "startnote"
        let endNoteKey = "endnote"
        let filenameKey = "filename"
        let triggerModeKey = "triggerMode"
        var loadSoundsArr = [NSMutableDictionary]()
        var sampleZoneXML = ""
        var layerXML = ""
        var sampleIDXML = ""
        var sampleIteration = 0
        let sampleNumStart = 268_435_457

        //iterate over the sounds
        for i in 0 ..< dict.count {
            let sound = dict.allValues[i] as! NSMutableDictionary
            var soundDict: NSMutableDictionary
            var alreadyLoaded = false
            var sampleNum = 0
            //soundDict = (sound as AnyObject).mutableCopy() as! NSMutableDictionary
            soundDict = NSMutableDictionary(dictionary: sound)
            //check if this sample is already loaded
            for loadedSoundDict in loadSoundsArr {
                let alreadyLoadedSound: String = loadedSoundDict.object(forKey: filenameKey) as! String
                let newLoadingSound: String = soundDict.object(forKey: filenameKey) as! String
                if alreadyLoadedSound == newLoadingSound {
                    alreadyLoaded = true
                    sampleNum = loadedSoundDict.object(forKey: "sampleNum") as! Int
                }
            }

            if (sound as AnyObject).object(forKey: startNoteKey) == nil || (sound as AnyObject).object(forKey: endNoteKey) == nil {
                soundDict.setObject((sound as AnyObject).object(forKey: rootNoteKey)!, forKey: startNoteKey as NSCopying)
                soundDict.setObject((sound as AnyObject).object(forKey: rootNoteKey)!, forKey: endNoteKey as NSCopying)
            }
            if (sound as AnyObject).object(forKey: rootNoteKey) == nil {
                //error
            } else {
                soundDict.setObject((sound as AnyObject).object(forKey: rootNoteKey)!, forKey: rootNoteKey as NSCopying)
            }

            if !alreadyLoaded { //if this is a new sound, then add it to samplefile xml
                sampleNum = sampleNumStart + sampleIteration
                let idXML = AKAUPresetBuilder.generateFileRef(wavRef: sampleNum, samplePath: (sound as AnyObject).object(forKey: "filename")! as! String)
                sampleIDXML.append(idXML)

                sampleIteration += 1
            }

            var startNote = soundDict.object(forKey: startNoteKey) as? MIDINoteNumber
            var endNote = soundDict.object(forKey: endNoteKey) as? MIDINoteNumber
            let rootNote = soundDict.object(forKey: rootNoteKey)! as! MIDINoteNumber
            startNote = (startNote == nil ? rootNote : startNote)
            endNote = (endNote == nil ? rootNote : endNote)
            let triggerModeStr = soundDict.object(forKey: triggerModeKey) as? String
            let triggerMode: SampleTriggerMode

            soundDict.setObject(sampleNum, forKey: "sampleNum" as NSCopying)
            loadSoundsArr.append(soundDict)

            let envelopesXML = AKAUPresetBuilder.generateEnvelope(id: 0, delay: 0, attack: attack!, hold: 0, decay: 0, sustain: 1, release: release!)
            switch triggerModeStr {
                case SampleTriggerMode.Loop.rawValue?:
                    triggerMode = SampleTriggerMode.Loop
                case SampleTriggerMode.Trigger.rawValue?:
                    triggerMode = SampleTriggerMode.Trigger
                case SampleTriggerMode.Hold.rawValue?:
                    triggerMode = SampleTriggerMode.Hold
                case SampleTriggerMode.Repeat.rawValue?:
                    triggerMode = SampleTriggerMode.Repeat
                default:
                    triggerMode = SampleTriggerMode.Trigger
            }
            switch triggerMode {
            case  .Hold:
                sampleZoneXML = AKAUPresetBuilder.generateZone(id: i, rootNote: rootNote, startNote: startNote!, endNote: endNote!, wavRef: sampleNum, loopEnabled: false)
                let tempLayerXML = AKAUPresetBuilder.generateLayer(connections: AKAUPresetBuilder.generateMinimalConnections(layer: i + 1), envelopes: envelopesXML, zones: sampleZoneXML, layer: i + 1, numVoices: 1, ignoreNoteOff: false)
                layerXML.append(tempLayerXML)
            case .Loop:
                sampleZoneXML = AKAUPresetBuilder.generateZone(id: i, rootNote: rootNote, startNote: startNote!, endNote: endNote!,
                                                               wavRef: sampleNum, loopEnabled: true)
                let tempLayerXML = AKAUPresetBuilder.generateLayer(connections: AKAUPresetBuilder.generateMinimalConnections(layer: i + 1), envelopes: envelopesXML, zones: sampleZoneXML, layer: i + 1, numVoices: 1, ignoreNoteOff: false)
                layerXML.append(tempLayerXML)
            default:
                //.Trigger and .Repeat (repeat needs to be handled in the app that uses this mode - otherwise is just the same as Trig mode)
                sampleZoneXML = AKAUPresetBuilder.generateZone(id: i, rootNote: rootNote, startNote: startNote!, endNote: endNote!, wavRef: sampleNum, loopEnabled: false)
                let tempLayerXML = AKAUPresetBuilder.generateLayer(connections: AKAUPresetBuilder.generateMinimalConnections(layer: i + 1), envelopes: envelopesXML, zones: sampleZoneXML, layer: i + 1, numVoices: 1, ignoreNoteOff: true)
                layerXML.append(tempLayerXML)

            }
        }

        let str = AKAUPresetBuilder.buildInstrument(name: instrumentName, filerefs: sampleIDXML, layers:layerXML)

        //write to file
        do {
            //AKLog("Writing to \(path)")
            try str.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            AKLog("Could not write to \(path)")
            AKLog("\(error)")
        }
    }

    /// This functions returns 1 dictionary entry for a particular sample zone. You then add this to an array, and feed that into createAUPreset
    ///
    /// - Parameters:
    ///   - rootNote:  Note at which the sample playback is unchanged
    ///   - filename:  Name of the file
    ///   - startNote: First note in range
    ///   - endNote:   Last note in range
    ///
    open static func generateDictionary(
        rootNote: Int,
        filename: String,
        startNote: Int,
        endNote: Int) -> NSMutableDictionary {

        let rootNoteKey = "rootnote"
        let startNoteKey = "startnote"
        let endNoteKey = "endnote"
        let filenameKey = "filename"
        let defaultObjects: [NSObject] = [rootNote as NSObject, startNote as NSObject, endNote as NSObject, filename as NSObject]
        let keys = [rootNoteKey, startNoteKey, endNoteKey, filenameKey]
        return NSMutableDictionary(objects: defaultObjects, forKeys: keys as [NSCopying])
    }

    static func spaces(_ count: Int) -> String {
        return String(repeating: String((" " as Character)), count: count)
    }

    /// Build the instrument file
    ///
    /// - Parameters:
    ///   - name:        Coded instrument name
    ///   - connections: Connection XML
    ///   - envelopes:   Envelopes XML
    ///   - filter:      Filter XML
    ///   - lfos:        Low Frequency Oscillator XML
    ///   - zones:       Zones XML
    ///   - filerefs:    File references XML
    ///   - layers:      Combined xml
    ///
    static open func buildInstrument(name: String = "Coded Instrument Name",
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
        presetXML.append(closeFileRefs())
        presetXML.append(generateFineTune())
        presetXML.append(generateGain())
        presetXML.append(generateManufacturer())
        presetXML.append(generateInstrument(name: name))
        presetXML.append(generateOutput())
        presetXML.append(generatePan())
        presetXML.append(generateTypeAndSubType())
        presetXML.append(generateVoiceCount())
        presetXML.append(closePreset())
        return presetXML
    }

    static func openPreset() -> String {
        var str: String = ""
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        str.append("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        str.append("<plist version=\"1.0\">\n")
        str.append("    <dict>\n")
        str.append("        <key>AU version</key>\n")
        str.append("        <real>1</real>\n")
        return str
    }

    static func openInstrument() -> String {
        var str: String = ""
        str.append("        <key>Instrument</key>\n")
        str.append("        <dict>\n")
        return str
    }

    static func openLayers() -> String {
        var str: String = ""
        str.append("            <key>Layers</key>\n")
        str.append("            <array>\n")
        return str
    }

    static func openLayer() -> String {
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

    static func openConnections() -> String {
        var str = ""
        str.append("                    <key>Connections</key>\n")
        str.append("                    <array>\n")
        return str
    }

    static func generateConnectionDict(id: Int,
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

    static func closeConnections() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }

    static func openEnvelopes() -> String {
        var str = ""
        str.append("                    <key>Envelopes</key>\n")
        str.append("                    <array>\n")
        return str
    }

    static func generateEnvelope(id: Int = 0,
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

    static func closeEnvelopes() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }

    static func generateFilter(cutoffHz: Double = 20_000.0, resonanceDb: Double = 0.0) -> String {
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

    static func generateID(_ id: Int = 0) -> String {
        var str = ""
        str.append("                    <key>ID</key>\n")
        str.append("                    <integer>\(id)</integer>\n")
        return str
    }

    static func openLFOs() -> String {
        var str = ""
        str.append("                    <key>LFOs</key>\n")
        str.append("                    <array>\n")
        return str
    }

    static func generateLFO(id: Int = 0,
                            delay: Double = 0.0,
                            rate: Double = 3.0,
                            waveform: Int = 0) -> String {
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

    static func closeLFOs() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }

    static func generateOscillator() -> String {
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

    static func openZones() -> String {
        var str = ""
        str.append("                    <key>Zones</key>\n")
        str.append("                    <array>\n")
        return str
    }

    static func generateZone(id: Int,
                             rootNote: MIDINoteNumber,
                             startNote: MIDINoteNumber,
                             endNote: MIDINoteNumber,
                             wavRef: Int = 268_435_457,
                             offset: Int = 0,
                             loopEnabled: Bool = false) -> String {
        let wavRefNum = wavRef + offset
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

    static func closeZones() -> String {
        var str = ""
        str.append("                    </array>\n")
        return str
    }

    static func layerIgnoreNoteOff(ignore: Bool = false) -> String {
        var str = ""
        if ignore {
            str.append("        <key>trigger mode</key>\n")
            str.append("        <integer>11</integer>\n")
        }
        return str
    }

    static func layerSet(voiceCount: Int = 16) -> String {
        var str = ""
        str.append("        <key>voice count</key>\n")
        str.append("        <integer>\(voiceCount)</integer>\n")
        return str
    }

    static func closeLayer() -> String {
        var str = ""
        str.append("                </dict>\n")
        return str
    }

    static func closeLayers() -> String {
        var str: String = ""
        str.append("            </array>\n")
        return str
    }

    static func closeInstrument(name: String = "Code Generated Instrument") -> String {
        var str: String = ""
        str.append("            <key>name</key>\n")
        str.append("            <string>\(name)</string>\n")
        str.append("        </dict>\n")
        return str
    }

    static func genCoarseTune(_ tune: Int = 0) -> String {
        var str: String = ""
        str.append("        <key>coarse tune</key>\n")
        str.append("        <integer>\(tune)</integer>\n")
        return str
    }

    static func genDataBlob() -> String {
        var str: String = ""
        str.append("        <key>data</key>\n")
        str.append("        <data>\n")
        str.append("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        str.append("        </data>\n")
        return str
    }

    static func openFileRefs() -> String {
        var str: String = ""
        str.append("        <key>file-references</key>\n")
        str.append("        <dict>\n")
        return str
    }

    static func generateFileRef(wavRef: Int = 268_435_457, samplePath: String) -> String {
        var str: String = ""
        str.append("            <key>Sample:\(wavRef)</key>\n")
        str.append("            <string>\(samplePath)</string>\n")
        return str
    }

    static func closeFileRefs() -> String {
        var str: String = ""
        str.append("        </dict>\n")
        return str
    }

    static func generateFineTune(_ tune: Double = 0.0) -> String {
        var str: String = ""
        str.append("        <key>fine tune</key>\n")
        str.append("        <real>\(tune)</real>\n")
        return str
    }

    static func generateGain(_ gain: Double = 0.0) -> String {
        var str: String = ""
        str.append("        <key>gain</key>\n")
        str.append("        <real>\(gain)</real>\n")
        return str
    }

    static func generateManufacturer(_ manufacturer: Int = 1_634_758_764) -> String {
        var str: String = ""
        str.append("        <key>manufacturer</key>\n")
        str.append("        <integer>\(manufacturer)</integer>\n")
        return str
    }

    static func generateInstrument(name: String = "Coded Instrument Name") -> String {
        var str: String = ""
        str.append("        <key>name</key>\n")
        str.append("        <string>\(name)</string>\n")
        return str
    }

    static func generateOutput(_ output: Int = 0) -> String {
        var str: String = ""
        str.append("        <key>output</key>\n")
        str.append("        <integer>\(output)</integer>\n")
        return str
    }

    static func generatePan(_ pan: Double = 0.0) -> String {
        var str: String = ""
        str.append("        <key>pan</key>\n")
        str.append("        <real>\(pan)</real>\n")
        return str
    }

    static func generateTypeAndSubType() -> String {
        var str: String = ""
        str.append("        <key>subtype</key>\n")
        str.append("        <integer>1935764848</integer>\n")
        str.append("        <key>type</key>\n")
        str.append("        <integer>1635085685</integer>\n")
        str.append("        <key>version</key>\n")
        str.append("        <integer>0</integer>\n")
        return str
    }

    static func generateVoiceCount(_ count: Int = 16) -> String {
        var str: String = ""
        str.append("        <key>voice count</key>\n")
        str.append("        <integer>\(count)</integer>\n")
        return str
    }

    static func closePreset() -> String {
        var str: String = ""
        str.append("    </dict>\n")
        str.append("</plist>\n")
        return str
    }

    static func generateLayer(connections: String,
                              envelopes: String = "",
                              filter: String = "",
                              lfos: String = "",
                              zones: String = "",
                              layer: Int = 0,
                              numVoices: Int = 16,
                              ignoreNoteOff: Bool = false) -> String {
        var str = ""
        str.append(openLayer())
        str.append(openConnections())
        str.append((connections == "" ? generateMinimalConnections(layer: layer) : connections))
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
        str.append(layerIgnoreNoteOff(ignore: ignoreNoteOff))
        str.append(generateVoiceCount(numVoices))
        str.append(closeLayer())
        return str
    }

    static func generateLayers(connections: [String], envelopes: [String], filters: [String], lfos: [String], zones: [String]) -> String {
        //make sure all arrays are same size
        var str = ""
        for i in 0..<connections.count {
            str.append(AKAUPresetBuilder.generateLayer(connections: connections[i], envelopes: envelopes[i], filter: filters[i], lfos: lfos[i], zones: zones[i], layer: i))
        }
        return str
    }

    static func generateMinimalConnections(layer: Int = 0) -> String {
        let layerOffset: Int = 256 * layer
        let pitchDest: Int = 816_840_704 + layerOffset
        let envelopeSource: Int = 536_870_912 + layerOffset
        let gainDest: Int = 1_343_225_856 + layerOffset
        var str = ""
        str.append(generateConnectionDict(id: 0, source: 300, destination: pitchDest, scale: 12_800, transform: 1, invert: false)) //keynum->pitch
        str.append(generateConnectionDict(id: 1, source: envelopeSource, destination: gainDest, scale: -96, transform: 1, invert: true)) //envelope->amp
        str.append(generateConnectionDict(id: 2, source: 301, destination: gainDest, scale: -96, transform: 2, invert: true))
        return str
    }

    static func genDefaultConnections() -> String {
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

public enum SampleTriggerMode: String {
    case Hold = "hold"
    case Trigger = "trigger"
    case Loop = "loop"
    case Repeat = "repeat"
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
