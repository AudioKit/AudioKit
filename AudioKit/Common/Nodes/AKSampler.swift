//
//  AKSampler.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/** Sampler audio generation. */
/*
 1) init the audio unit like this: var sampler = AKSampler()
 2) load a sound a file: sampler.loadWav("path/to/your/sound/file/in/app/bundle") (without wav extension)
 3) connect to the avengine: audiokit.audioOutput = sampler
 4) start the avengine audiokit.start()
*/
public class AKSampler: AKNode {
    
    // MARK: - Properties
    
    private var internalAU: AUAudioUnit?
    private var token: AUParameterObserverToken?
    var samplerUnit = AVAudioUnitSampler()
    public var midiIn = MIDIEndpointRef()
    var midiClient = MIDIClientRef()
    
    // MARK: - Initializers
    
    /** Initialize the sampler node */
    public override init() {
        super.init()
        
        self.output = samplerUnit
        self.internalAU = samplerUnit.AUAudioUnit
        AKManager.sharedInstance.engine.attachNode(self.output!)
        //you still need to connect the output, and you must do this before starting the processing graph
    }//end init
    
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
    public func loadEXS24(file: String) {
        loadInstrument(file, type: "exs")
    }
    public func loadSoundfont(file: String) {
        loadInstrument(file, type: "sf2")
    }
    func loadInstrument(file: String, type: String) {
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
    
    // MARK: - Playback
    public func playNote(note: Int = 60, velocity: Int = 127, channel: Int = 0) {
//        samplerUnit.startNote(UInt8(note), withVelocity: UInt8(velocity), onChannel: UInt8(channel))
        MusicDeviceMIDIEvent(samplerUnit.audioUnit, 0x90, UInt32(note), UInt32(velocity), 0)
    }
    public func stopNote(note: Int = 60, channel: Int = 0) {
        samplerUnit.stopNote(UInt8(note), onChannel: UInt8(channel))
    }
    
    
    //the following should be included in any midi instrument
    public func enableMidi(midiClient: MIDIClientRef, name:String){
        MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
            let numPackets = Int(packetList.memory.numPackets)
            let packet = packetList.memory.packet as MIDIPacket
            var packetPtr: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
            packetPtr.initialize(packet)
            
            for var i = 0; i < numPackets; ++i {
                let event = AKMidiEvent(packet: packetPtr.memory)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMidi
                MusicDeviceMIDIEvent(samplerUnit.audioUnit, UInt32(event.internalData[0]), UInt32(event.internalData[1]), UInt32(event.internalData[2]), 0)
                packetPtr = MIDIPacketNext(packetPtr)
            }
    }
    //end midi functionality
}
