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
    public var sequencePointer:UnsafeMutablePointer<MusicSequence>
    var musicPlayer:MusicPlayer = nil
    public var loopEnabled:Bool = false
    
    public init() {
        NewMusicSequence(&sequence)
        sequencePointer = UnsafeMutablePointer<MusicSequence>(sequence)
        
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
    
    //set loop functionality of entire sequence
    public func loopToggle(){
        (loopEnabled ? loopOff() : loopOn())
    }
    public func loopOn(){
        setLoopInfo(length, numLoops: 0)
        loopEnabled = true
    }
    public func loopOff(){
        setLoopInfo(0, numLoops: 0)
        loopEnabled = false
    }
    //set looping of all tracks
    public func setLoopInfo(duration:Double, numLoops:Int){
        let size:UInt32 = 0
        let num:Int32 = Int32(numLoops)
        let len = MusicTimeStamp(duration)
        var loopInfo = MusicTrackLoopInfo(loopDuration: len, numberOfLoops: num)
        for( var i = 0; i < self.numTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_LoopInfo, &loopInfo, size)
        }
    }
    //set length of all tracks
    public func setLength(length:Double){
        let size:UInt32 = 0
        var len = MusicTimeStamp(length)
        for( var i = 0; i < self.numTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &len, size)
        }
    }
    
    //length is length of longest track in the sequence
    public var length:Double{
        var length:MusicTimeStamp = 0
        var tmpLength:MusicTimeStamp = 0
        var size:UInt32 = 0
        for( var i = 0; i < self.numTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            MusicTrackGetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &tmpLength, &size)
            if(tmpLength >= length){ length = tmpLength }
        }
        return Double(length)
    }
    
    public func play(){
        MusicPlayerStart(musicPlayer)
    }
    public func stop(){
        MusicPlayerStop(musicPlayer)
    }
    public func rewind(){
        MusicPlayerSetTime(musicPlayer, 0)
    }
    
    public func setGlobalMidiOutput(midiOut:AKMidi, index:Int = 0){
        for( var i = 0; i < self.numTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            MusicTrackSetDestMIDIEndpoint(musicTrack, midiOut.midiEndpoints[index])
        }
    }
    
    public var numTracks:Int{
        var count:UInt32 = 0
        MusicSequenceGetTrackCount(sequence, &count)
        return Int(count)
    }
    
    public func loadMidiFile(filename:String){
        let bundle = NSBundle.mainBundle()
        let file = bundle.pathForResource(filename, ofType: "mid")
        let fileURL = NSURL.fileURLWithPath(file!)
        MusicSequenceFileLoad(sequence, fileURL, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
    }
}//end AKSequencer