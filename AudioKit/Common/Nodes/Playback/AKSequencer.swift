//
//  AKSequencer.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 11/27/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** Basic sequencer */
/*  note: this file is currently in transistion from old c core audio apis, to the more modern avaudiosequencer setup.
    however, the new system is not as advanced as the old, so we will keep both and have them interact.
    as such, there is some code hanging around while we iron it out.
 */
public class AKSequencer {
    
    public var sequence:MusicSequence = nil
    public var sequencePointer:UnsafeMutablePointer<MusicSequence>
    public var avSeq = AVAudioSequencer()
    
    public var tracks:[AKMusicTrack] = []
    
    public var rawTracks:[AVMusicTrack]{
        return avSeq.tracks
    }
    
    var musicPlayer:MusicPlayer = nil
    public var loopEnabled:Bool = false
    
    public init() {
        NewMusicSequence(&sequence)
        sequencePointer = UnsafeMutablePointer<MusicSequence>(sequence)
        
        //setup and attach to musicplayer
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer, sequence)
    }
    
    //inits the sequence with a midi file
    public convenience init(filename:String){
        self.init()
        loadMidiFile(filename)
    }
    
    //inits the sequence with a midi file and audioengine
    public convenience init(filename:String, engine:AVAudioEngine){
        self.init()
        avSeq = AVAudioSequencer(audioEngine: engine)
        loadMidiFile(filename)
    }
    
    //set loop functionality of entire sequence
    public func loopToggle(){
        (loopEnabled ? loopOff() : loopOn())
    }
    public func loopOn(){
        setLoopInfo(length, numLoops: 0)
        for track in avSeq.tracks{
            track.loopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, self.length)
        }
        loopEnabled = true
    }
    public func loopOff(){
        setLoopInfo(0, numLoops: 0)
        for track in avSeq.tracks{
            track.loopingEnabled = false
        }
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
        for track in avSeq.tracks{
            track.lengthInBeats = len
            track.loopRange = AVMakeBeatRange(0, self.length)
        }
    }
    
    //length is length of longest track in the sequence
    public var length:Double{
        var length:MusicTimeStamp = 0
        var tmpLength:MusicTimeStamp = 0
//        var size:UInt32 = 0
//        for( var i = 0; i < self.numTracks; ++i){
//            var musicTrack = MusicTrack()
//            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
//            MusicTrackGetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &tmpLength, &size)
//            if(tmpLength >= length){ length = tmpLength }
//        }
        for track in avSeq.tracks{
            tmpLength = track.lengthInBeats
            if(tmpLength >= length){ length = tmpLength }
        }
        return Double(length)
    }
    
    public func play(){
//        MusicPlayerStart(musicPlayer)
        do{
            try avSeq.start()
        }catch _{
            print("could not start avSeq")
        }
    }
    public func stop(){
//        MusicPlayerStop(musicPlayer)
        avSeq.stop()
    }
    public func rewind(){
//        MusicPlayerSetTime(musicPlayer, 0)
        avSeq.currentPositionInBeats = 0
    }
    
    public func setGlobalMidiOutput(midiEndpoint:MIDIEndpointRef){
//        for trackInd in tracks{
//            MusicTrackSetDestMIDIEndpoint(trackInd.internalMusicTrack, midiEndpoint)
//        }
        for track in avSeq.tracks{
            track.destinationMIDIEndpoint = midiEndpoint
        }
    }
    
    public func setGlobalAVAudioUnitOutput(inUnit:AVAudioUnit){
        for track in avSeq.tracks{
            track.destinationAudioUnit = inUnit
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
        
        do {
           try avSeq.loadFromURL(fileURL, options: AVMusicSequenceLoadOptions.SMF_PreserveTracks)
        }catch _ {
            print("failed to load midi into avseq")
        }
        initTracks()
    }
    
    func initTracks(){
        tracks.removeAll()
        for( var i = 0; i < self.numTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            tracks.append(AKMusicTrack(musicTrack: musicTrack))
        }
    }
    
}//end AKSequencer