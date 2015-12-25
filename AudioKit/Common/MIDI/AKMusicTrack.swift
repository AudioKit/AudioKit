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
    
    internal var internalMusicTrack = MusicTrack()
    
    /// Pointer to the Music Track
    public var trackPtr:UnsafeMutablePointer<MusicTrack>
    
    /** Initialize with a music track
     
     - parameter musicTrack: An Apple Music Track
     */
    public init(musicTrack: MusicTrack) {
        internalMusicTrack = musicTrack
        trackPtr = UnsafeMutablePointer<MusicTrack>(internalMusicTrack)
    }
    
    /** Set the MIDI Ouput

     - parameter endpoint: MIDI Endpoint Port
     */
    public func setMidiOutput(endpoint:MIDIEndpointRef) {
        MusicTrackSetDestMIDIEndpoint(internalMusicTrack, endpoint)
    }
    
    /** Set the Node Output

     - parameter node: Apple AUNode for output
     */
    public func setNodeOutput(node: AUNode) {
        MusicTrackSetDestNode(internalMusicTrack, node)
    }
}