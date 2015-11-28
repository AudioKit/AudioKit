//
//  AKSequencer.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 11/27/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Basic sequencer */
public class AKSequencer{
    
    public var sequence:MusicSequence = nil
    public var seqPtr:UnsafeMutablePointer<MusicSequence>
    var musicPlayer:MusicPlayer = nil
    
    public init() {
        NewMusicSequence(&sequence)
        seqPtr = UnsafeMutablePointer<MusicSequence>(sequence)
        
        //setup and attach to musicplayer
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer, sequence)
        
        print("howdy from sequencer")
    }
    
    //inits the sequence with a midi file
    public convenience init(filename:String){
        self.init()
        loadMidiFile(filename)
    }
    
    public func loadMidiFile(filename:String){
        let bundle = NSBundle.mainBundle()
        let file = bundle.pathForResource(filename, ofType: "mid")
        let fileURL = NSURL.fileURLWithPath(file!)
        var status = MusicSequenceFileLoad(sequence, fileURL, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
    }
}