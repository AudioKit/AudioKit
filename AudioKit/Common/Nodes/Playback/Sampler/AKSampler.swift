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
    
    
    /// Load a AUPreset sample data file
    ///
    /// - parameter file: Name of the AUPreset file without the .aupreset extension
    ///
    public func loadAUPreset(file: String) {
        loadInstrument(file, type: "aupreset")
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
    
    /* loadSamplesFromDict
    Dictionary is a collection of other dictionaries that have the format like this:
    ***Key:Value***
    rootnote:int
    startnote:int
    endnote:int
    filename:string -
    
    
    */
    public func loadSamplesFromDict(dict:NSDictionary){
        let rootNoteKeyStr = "rootnote"
        let startNoteKeyStr = "startnote"
        let endNoteKeyStr = "endnote"
        let filenameKeyStr = "filename"
        var loadSoundsArr = Array<NSMutableDictionary>()
        var sampleZoneXML:String = String()
        var sampleIDXML:String = String()
        var sampleIteration = 0
        let sampleNumStart = 268435457
        
        //first iterate over the sound packs
        for (var i = 0; i < dict.count; i++){
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
            
            if(sound.objectForKey(startNoteKeyStr) == nil || sound.objectForKey(endNoteKeyStr) == nil ){
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
                let sampleNumString = "<key>Sample:\(sampleNum)</key>"
                let sampleLocString = "<string>\(sound.objectForKey("filename")!)</string>\n"
                
                soundDict.setObject(sampleNumString, forKey: "sampleNumString")
                soundDict.setObject(sampleLocString, forKey: "sampleLocString")
                sampleIDXML.appendContentsOf("\(sampleNumString)\n\(sampleLocString)")
                sampleIteration++;
            }
            let tempSampleZoneXML:String = "<dict>\n" +
                "<key>ID</key>\n" +
                "<integer>\(sampleIteration)</integer>\n" +
                "<key>enabled</key>\n" +
                "<true/>\n" +
                "<key>loop enabled</key>\n" +
                "<false/>\n" +
                "<key>max key</key>\n" +
                "<integer>\(soundDict.objectForKey(endNoteKeyStr)!)</integer>\n" +
                "<key>min key</key>\n" +
                "<integer>\(soundDict.objectForKey(startNoteKeyStr)!)</integer>\n" +
                "<key>root key</key>\n" +
                "<integer>\(soundDict.objectForKey(rootNoteKeyStr)!)</integer>\n" +
                "<key>waveform</key>\n" +
                "<integer>\(sampleNum)</integer>\n" +
            "</dict>\n"
            sampleZoneXML.appendContentsOf(tempSampleZoneXML)
            soundDict.setObject(sampleNum, forKey: "sampleNum")
            loadSoundsArr.append(soundDict)
        }//end iterate soundPack
        
        print(sampleZoneXML)
        print(sampleIDXML)
        
        //let newpreset = writeAUPreset("soundName", fileName: "SamplePreset2", zoneStr: sampleZoneXML, samplesStr: sampleIDXML)
        
    }//end func loadSamplesFromDict
    
//    func writeAUPreset(instName:String, fileName:String, zoneStr:String, samplesStr:String)->String{
//        let path = NSBundle.mainBundle().pathForResource("Sounds/AUSamplerTemplate", ofType: "xml")
//        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//        createDir("soundpacks")
//        let writePath = documents.stringByAppendingString("/soundpacks/\(fileName).aupreset")
//        var newStr = String()
//        do{
//            let templateStr = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
//            newStr = templateStr.stringByReplacingOccurrencesOfString("***INSTNAME***", withString: instName)
//            print(zoneStr)
//            newStr = newStr.stringByReplacingOccurrencesOfString("***ZONEMAPPINGS***", withString: zoneStr)
//            print(samplesStr)
//            newStr = newStr.stringByReplacingOccurrencesOfString("***SAMPLEFILES***", withString: samplesStr)
//        }catch let error as NSError {
//            print(error)
//        }
//        //write to file
//        do{
//            print(writePath)
//            try newStr.writeToFile(writePath, atomically: true, encoding: NSUTF8StringEncoding)
//            return writePath
//        }catch let error as NSError {
//            print(error)
//            return ""
//        }
//    }

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
