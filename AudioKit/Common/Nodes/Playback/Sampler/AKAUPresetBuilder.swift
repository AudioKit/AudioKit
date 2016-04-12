//
//  AUPresetTemplate.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/7/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKAUPresetBuilder{
    
    public var presetXML:String = ""
    public var layers:[String] = Array()
    public var connections:[String] = Array()
    public var envelopes:[String] = Array()
    public var lfos:[String] = Array()
    public var zones:[String] = Array()
    public var fileRefs:[String] = Array()
    public var filters:[String] = Array()
    
    init(name:String = "Coded Instrument Name",
         connections:String = "***CONNECTIONS***\n",
         envelopes:String = "***ENVELOPES***\n",
         filter:String = "***FILTER***\n",
         lfos:String = "***LFOS***\n",
         zones:String = "***ZONES***\n",
         filerefs:String = "***FILEREFS***\n"){
        presetXML = AKAUPresetBuilder.buildInstrument(name, connections: connections, envelopes: envelopes, filter: filter, lfos: lfos, zones: zones,filerefs: filerefs)
    }
    
    
    /* createAUPresetFromDict
     dict is a collection of other dictionaries that have the format like this:
     ***Key:Value***
     filename:string
     rootnote:int
     startnote:int (optional)
     endnote:int (optional)
     path is where the aupreset will be created
     instName is the name of the aupreset
     */
    static public func createAUPresetFromDict(dict:NSDictionary, path:String, instName:String, attack:Double? = 0, release:Double? = 0){
        let rootNoteKeyStr = "rootnote"
        let startNoteKeyStr = "startnote"
        let endNoteKeyStr = "endnote"
        let filenameKeyStr = "filename"
        var loadSoundsArr = Array<NSMutableDictionary>()
        var sampleZoneXML:String = String()
        var sampleIDXML:String = String()
        var sampleIteration = 0
        let sampleNumStart = 268435457
        
        //iterate over the sounds
        for i in 0..<dict.count{
            let sound = dict.allValues[i]
            var soundDict:NSMutableDictionary
            var alreadyLoaded = false
            var sampleNum:Int = 0
            soundDict = sound.mutableCopy() as! NSMutableDictionary
            //check if this sample is already loaded
            for loadedSoundDict in loadSoundsArr{
                let alreadyLoadedSound:String = loadedSoundDict.objectForKey(filenameKeyStr) as! String
                let newLoadingSound:String = soundDict.objectForKey(filenameKeyStr) as! String
                if ( alreadyLoadedSound == newLoadingSound){
                    alreadyLoaded = true
                    sampleNum = loadedSoundDict.objectForKey("sampleNum") as! Int
                }
            }
            
            if(sound.objectForKey(startNoteKeyStr) == nil
                || sound.objectForKey(endNoteKeyStr) == nil){
                soundDict.setObject(sound.objectForKey(rootNoteKeyStr)!, forKey: startNoteKeyStr)
                soundDict.setObject(sound.objectForKey(rootNoteKeyStr)!, forKey: endNoteKeyStr)
            }
            if(sound.objectForKey(rootNoteKeyStr) == nil){
                //error
            }else{
                soundDict.setObject(sound.objectForKey(rootNoteKeyStr)!, forKey: rootNoteKeyStr)
            }
            if(!alreadyLoaded){ //if this is a new sound, then add it to samplefile xml
                sampleNum = sampleNumStart + sampleIteration
                let idXML = AKAUPresetBuilder.generateFileRef(sampleNum, samplePath: sound.objectForKey("filename")! as! String)
                sampleIDXML.appendContentsOf(idXML)
                
                sampleIteration += 1;
            }
            let startNote = soundDict.objectForKey(startNoteKeyStr)! as! Int
            let endNote = soundDict.objectForKey(endNoteKeyStr)! as! Int
            let rootNote = soundDict.objectForKey(rootNoteKeyStr)! as! Int
            let tempSampleZoneXML:String = AKAUPresetBuilder.generateZone(i, rootNote: rootNote, startNote: startNote, endNote: endNote, wavRef: sampleNum)
            
            sampleZoneXML.appendContentsOf(tempSampleZoneXML)
            soundDict.setObject(sampleNum, forKey: "sampleNum")
            loadSoundsArr.append(soundDict)
        }//end sounds
        
        let envelopesXML = AKAUPresetBuilder.generateEnvelope(0, delay: 0, attack: attack!, hold: 0, decay: 0, sustain: 1, release: release!)
        let templateStr = AKAUPresetBuilder.buildInstrument(instName, envelopes: envelopesXML, zones: sampleZoneXML, filerefs: sampleIDXML)
        
        //print(templateStr) //debug
        //write to file
        do{
            print("Writing to \(path)")
            try templateStr.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        }catch let error as NSError {
            print(error)
        }
    }//end func createAUPresetFromDict
    
    // This functions returns 1 dictionary entry for a particular sample zone. You then add this to an array, and feed that
    // into createAUPresetFromDict
    public static func generateTemplateDictionary(
        rootNote: Int,
        filename: String,
        startNote: Int,
        endNote: Int) -> NSMutableDictionary {
        
        let rootNoteKeyStr = "rootnote"
        let startNoteKeyStr = "startnote"
        let endNoteKeyStr = "endnote"
        let filenameKeyStr = "filename"
        let defaultObjects:[NSObject] = [rootNote, startNote, endNote, filename]
        let keys: [String] = [rootNoteKeyStr, startNoteKeyStr, endNoteKeyStr, filenameKeyStr]
        return NSMutableDictionary.init(objects: defaultObjects, forKeys: keys)
    }

    static public func buildInstrument( name:String = "Coded Instrument Name",
                                        connections:String = "",
                                        envelopes:String = "",
                                        filter:String = "",
                                        lfos:String = "",
                                        zones:String = "***ZONES***\n",
                                        filerefs:String = "***FILEREFS***\n",
                                        layers:String = ""
                                )->String{
        var presetXML = openPreset()
        presetXML.appendContentsOf(openInstrument())
        presetXML.appendContentsOf(openLayers())
        if(layers == ""){
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
        }else{
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
    static public func openPreset()->String{
        var templateStr:String = ""
        templateStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        templateStr.appendContentsOf("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        templateStr.appendContentsOf("<plist version=\"1.0\">\n")
        templateStr.appendContentsOf("    <dict>\n")
        templateStr.appendContentsOf("        <key>AU version</key>\n")
        templateStr.appendContentsOf("        <real>1</real>\n")
        return templateStr
    }
    static public func openInstrument()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>Instrument</key>\n")
        templateStr.appendContentsOf("        <dict>\n")
        return templateStr
    }
    static public func openLayers()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("            <key>Layers</key>\n")
        templateStr.appendContentsOf("            <array>\n")
        return templateStr
    }
    static public func openLayer()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                <dict>\n")
        templateStr.appendContentsOf("                    <key>Amplifier</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <true/>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        return templateStr
    }
    static public func openConnections()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>Connections</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        return templateStr
    }
    static public func generateConnectionDict(id:Int,
                                                source:Int,
                                                destination:Int,
                                                scale:Int,
                                                transform:Int = 1,
                                                invert:Bool = false)->String{
        var templateStr = ""
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>\(id)</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>\(destination)</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <\((invert ? "true" : "false"))/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>\(scale)</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>\(source)</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        return templateStr
    }
    static public func closeConnections()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    </array>\n")
        return templateStr
    }
    static public func openEnvelopes()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>Envelopes</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        return templateStr
    }
    static public func generateEnvelope(id:Int = 0,
                                         delay:Double = 0.0,
                                         attack:Double = 0.0,
                                         hold:Double = 0.0,
                                         decay:Double = 0.0,
                                         sustain:Double = 1.0,
                                         release:Double = 0.0)->String{
        var templateStr = ""
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>\(id)</integer>\n")
        templateStr.appendContentsOf("                            <key>Stages</key>\n")
        templateStr.appendContentsOf("                            <array>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>0</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>\(delay)</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>22</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>1</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>\(attack)</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>2</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>\(hold)</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>3</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>\(decay)</real>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>level</key>\n")
        templateStr.appendContentsOf("                                    <real>\(sustain)</real>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>4</integer>\n")
        templateStr.appendContentsOf("                                </dict>\n")
        templateStr.appendContentsOf("                                <dict>\n")
        templateStr.appendContentsOf("                                    <key>curve</key>\n")
        templateStr.appendContentsOf("                                    <integer>20</integer>\n")
        templateStr.appendContentsOf("                                    <key>stage</key>\n")
        templateStr.appendContentsOf("                                    <integer>5</integer>\n")
        templateStr.appendContentsOf("                                    <key>time</key>\n")
        templateStr.appendContentsOf("                                    <real>\(release)</real>\n")
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
        return templateStr
    }
    static public func closeEnvelopes()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    </array>\n")
        return templateStr
    }
    static public func generateFilter(cutoffHz:Double = 20000.0, resonanceDb:Double = 0.0)->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>Filters</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>cutoff</key>\n")
        templateStr.appendContentsOf("                        <real>\(cutoffHz)</real>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <false/>\n")
        templateStr.appendContentsOf("                        <key>resonance</key>\n")
        templateStr.appendContentsOf("                        <real>\(resonanceDb)</real>\n")
        templateStr.appendContentsOf("                        <key>type</key>\n")
        templateStr.appendContentsOf("                        <integer>40</integer>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        return templateStr
    }
    static public func generateID(id:Int = 0)->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>ID</key>\n")
        templateStr.appendContentsOf("                    <integer>\(id)</integer>\n")
        return templateStr
    }
    static public func openLFOs()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>LFOs</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        return templateStr
    }
    static public func generateLFO(id:Int = 0, delay:Double = 0.0, rate:Double = 3.0, waveform:Int = 0)->String{
        //0 = triangle, 29 = reverseSaw, 26 = saw, 28 = square, 25 = sine, 75 = sample/hold, 76 = randomInterpolated
        var templateStr = ""
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>\(id)</integer>\n")
        templateStr.appendContentsOf("                            <key>delay</key>\n")
        templateStr.appendContentsOf("                            <real>\(delay)</real>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>rate</key>\n")
        templateStr.appendContentsOf("                            <real>\(rate)</real>\n")
        if(waveform != 0){ //if triangle, this section is just not added
            templateStr.appendContentsOf("                            <key>waveform</key>\n")
            templateStr.appendContentsOf("                            <integer>\(waveform)</integer>\n")
        }
        templateStr.appendContentsOf("                        </dict>\n")
        return templateStr
    }
    static public func closeLFOs()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    </array>\n")
        return templateStr
    }
    static public func generateOscillator()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>Oscillator</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <true/>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        return templateStr
    }
    static public func openZones()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>Zones</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        return templateStr
    }
    static public func generateZone(id:Int, rootNote:Int, startNote:Int, endNote:Int, wavRef:Int = 268435457, offset:Int = 0)->String{
        let wavRefNum = wavRef+offset
        var templateStr = ""
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>\(id)</integer>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <true/>\n")
        templateStr.appendContentsOf("                        <key>loop enabled</key>\n")
        templateStr.appendContentsOf("                        <false/>\n")
        templateStr.appendContentsOf("                        <key>max key</key>\n")
        templateStr.appendContentsOf("                        <integer>\(endNote)</integer>\n")
        templateStr.appendContentsOf("                        <key>min key</key>\n")
        templateStr.appendContentsOf("                        <integer>\(startNote)</integer>\n")
        templateStr.appendContentsOf("                        <key>root key</key>\n")
        templateStr.appendContentsOf("                        <integer>\(rootNote)</integer>\n")
        templateStr.appendContentsOf("                        <key>waveform</key>\n")
        templateStr.appendContentsOf("                        <integer>\(wavRefNum)</integer>\n")
        templateStr.appendContentsOf("                     </dict>\n")
        return templateStr
    }
    static public func closeZones()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    </array>\n")
        return templateStr
    }
    static public func closeLayer()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                </dict>\n")
        return templateStr
    }
    static public func closeLayers()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("            </array>\n")
        return templateStr
    }
    static public func closeInstrument(name:String = "Code Generated Instrument")->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("            <key>name</key>\n")
        templateStr.appendContentsOf("            <string>\(name)</string>\n")
        templateStr.appendContentsOf("        </dict>\n")
        return templateStr
    }
    static public func genCoarseTune(tune:Int = 0)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>coarse tune</key>\n")
        templateStr.appendContentsOf("        <integer>\(tune)</integer>\n")
        return templateStr
    }
    static public func genDataBlob()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>data</key>\n")
        templateStr.appendContentsOf("        <data>\n")
        templateStr.appendContentsOf("            AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=\n")
        templateStr.appendContentsOf("        </data>\n")
        return templateStr
    }
    static public func openFileRefs()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>file-references</key>\n")
        templateStr.appendContentsOf("        <dict>\n")
        return templateStr
    }
    static public func generateFileRef(wavRef:Int = 268435457, samplePath:String)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("            <key>Sample:\(wavRef)</key>\n")
        templateStr.appendContentsOf("            <string>\(samplePath)</string>\n")
        return templateStr
    }
    static public func closeFileRefs()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        </dict>\n")
        return templateStr
    }
    static public func generateFineTune(tune:Double = 0.0)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>fine tune</key>\n")
        templateStr.appendContentsOf("        <real>\(tune)</real>\n")
        return templateStr
    }
    static public func generateGain(gain:Double = 0.0)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>gain</key>\n")
        templateStr.appendContentsOf("        <real>\(gain)</real>\n")
        return templateStr
    }
    static public func generateManufacturer(manufacturer:Int = 1634758764)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>manufacturer</key>\n")
        templateStr.appendContentsOf("        <integer>\(manufacturer)</integer>\n")
        return templateStr
    }
    static public func generateInstrumentName(name:String = "Coded Instrument Name")->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>name</key>\n")
        templateStr.appendContentsOf("        <string>\(name)</string>\n")
        return templateStr
    }
    static public func generateOutput(output:Int = 0)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>output</key>\n")
        templateStr.appendContentsOf("        <integer>\(output)</integer>\n")
        return templateStr
    }
    static public func generatePan(pan:Double = 0.0)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>pan</key>\n")
        templateStr.appendContentsOf("        <real>\(pan)</real>\n")
        return templateStr
    }
    static public func generateTypeAndSubType()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>subtype</key>\n")
        templateStr.appendContentsOf("        <integer>1935764848</integer>\n")
        templateStr.appendContentsOf("        <key>type</key>\n")
        templateStr.appendContentsOf("        <integer>1635085685</integer>\n")
        templateStr.appendContentsOf("        <key>version</key>\n")
        templateStr.appendContentsOf("        <integer>0</integer>\n")
        return templateStr
    }
    static public func generateVoiceCount(count:Int = 16)->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("        <key>voice count</key>\n")
        templateStr.appendContentsOf("        <integer>\(count)</integer>\n")
        return templateStr
    }
    static public func closePreset()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("    </dict>\n")
        templateStr.appendContentsOf("</plist>\n")
        return templateStr
    }
    
    static public func generateLayer(connections:String, envelopes:String = "", filter:String = "", lfos:String = "", zones:String = "", layer:Int = 0)->String{
        var templateStr = ""
        templateStr.appendContentsOf(openLayer())
        templateStr.appendContentsOf(openConnections())
        templateStr.appendContentsOf((connections == "" ? generateMinimalConnections(layer) : connections))
        templateStr.appendContentsOf(closeConnections())
        templateStr.appendContentsOf(openEnvelopes())
        templateStr.appendContentsOf((envelopes == "" ? generateEnvelope() : envelopes))
        templateStr.appendContentsOf(closeEnvelopes())
        templateStr.appendContentsOf((filter == "" ? generateFilter() : filter))
        templateStr.appendContentsOf(generateID(layer))
        templateStr.appendContentsOf(openLFOs())
        templateStr.appendContentsOf((lfos == "" ? generateLFO() : lfos))
        templateStr.appendContentsOf(closeLFOs())
        templateStr.appendContentsOf(generateOscillator())
        templateStr.appendContentsOf(openZones())
        templateStr.appendContentsOf(zones)
        templateStr.appendContentsOf(closeZones())
        templateStr.appendContentsOf(closeLayer())
        return templateStr
    }
    static public func generateLayers(connections:[String], envelopes:[String], filters:[String], lfos:[String], zones:[String])->String{
        //make sure all arrays are same size
        var templateStr = ""
        for i in 0..<connections.count{
            templateStr.appendContentsOf(AKAUPresetBuilder.generateLayer(connections[i], envelopes: envelopes[i], filter: filters[i], lfos: lfos[i], zones: zones[i], layer: i))
        }
        return templateStr
    }
    static public func generateMinimalConnections(layer:Int = 0)->String{
        let layerOffset:Int = 256*layer
        let pitchDest:Int = 816840704+layerOffset
        let envelopeSource:Int = 536870912+layerOffset
        let gainDest:Int = 1343225856+layerOffset
         var templateStr = ""
        templateStr.appendContentsOf(generateConnectionDict(0, source: 300, destination: pitchDest, scale: 12800, transform: 1, invert: false)) //keynum->pitch
        templateStr.appendContentsOf(generateConnectionDict(1, source: envelopeSource, destination: gainDest, scale: -96, transform: 1, invert: true)) //envelope->amp
        templateStr.appendContentsOf(generateConnectionDict(2, source: 301, destination: gainDest, scale: -96, transform: 2, invert: true))
        return templateStr
    }
    static public func genDefaultConnections()->String{
        var templateStr = ""
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
        return templateStr
    }
    
    static func genFULLXML()->String{
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
        templateStr.appendContentsOf("                            <key>delay</key>\n")
        templateStr.appendContentsOf("                            <real>0.069456316530704498</real>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>rate</key>\n")
        templateStr.appendContentsOf("                            <real>10.117301940917969</real>\n")
        templateStr.appendContentsOf("                            <key>waveform</key>\n")
        templateStr.appendContentsOf("                            <integer>25</integer>\n")
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