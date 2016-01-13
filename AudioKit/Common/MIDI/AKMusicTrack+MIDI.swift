//
//  AKMusicTrack+MIDI.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/10/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKMusicTrack {
    
    /// Set the MIDI Ouput
    ///
    /// - parameter endpoint: MIDI Endpoint Port
    ///
    public func setMIDIOutput(endpoint: MIDIEndpointRef) {
        MusicTrackSetDestMIDIEndpoint(internalMusicTrack, endpoint)
    }
    
}