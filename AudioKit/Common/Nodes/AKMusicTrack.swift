//
//  AKMusicTrack.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 12/8/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Wrapper for internal apple MusicTrack */
public class AKMusicTrack{
    
    var internalMusicTrack = MusicTrack()
    public var trackPtr:UnsafeMutablePointer<MusicTrack>
    
    public init(musicTrack: MusicTrack){
        internalMusicTrack = musicTrack
        trackPtr = UnsafeMutablePointer<MusicTrack>(internalMusicTrack)
    }
    
    public func setMidiOutput(endpoint:MIDIEndpointRef){
        MusicTrackSetDestMIDIEndpoint(internalMusicTrack, endpoint)
    }
    
    public func setOutputNode(node:AUNode){
        MusicTrackSetDestNode(internalMusicTrack, node)
    }
}