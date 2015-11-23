//
//  AKAUSampler.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/** Sampler audio generation. */
public class AKAUSampler: AKOperation {
    
    // MARK: - Properties
    
    private var internalAU: AUAudioUnit?
    private var token: AUParameterObserverToken?
    var samplerUnit = AVAudioUnitSampler()
    
    // MARK: - Initializers
    
    /** Initialize the sampler operation */
    public override init() {
        super.init()
        
        self.output = samplerUnit
        self.internalAU = samplerUnit.AUAudioUnit
        AKManager.sharedInstance.engine.attachNode(self.output!)
        //you still need to connect the output, and you must do this before starting the processing graph
    }//end init
    
    public func loadWav(file: String){
        guard let url = NSBundle.mainBundle().URLForResource(file, withExtension: "wav")
            else{
                fatalError("file not found.")
        }
        let files:[NSURL] = [url]
        do{
            try samplerUnit.loadAudioFilesAtURLs(files)
        }catch{
            print("error")
        }
    }
    public func loadEXS24(file: String){
        loadInstrument(file,type: "exs")
    }
    public func loadSoundfont(file: String){
        loadInstrument(file,type: "sf2")
    }
    func loadInstrument(file: String, type: String){
        print("filename is \(file)")
        guard let url = NSBundle.mainBundle().URLForResource(file, withExtension: type)
            else{
                fatalError("file not found.")
        }
        do{
            try samplerUnit.loadInstrumentAtURL(url)
        }catch{
            print("error")
        }
    }
    
    // MARK: - Playback
    public func playNote(note: Int = 60, vel: Int = 127, chan: Int = 0){
        samplerUnit.startNote(UInt8(note), withVelocity: UInt8(vel), onChannel: UInt8(chan))
    }
    public func stopNote(note: Int = 60, chan: Int = 0){
        samplerUnit.stopNote(UInt8(note), onChannel: UInt8(chan))
    }
}
