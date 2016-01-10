//
//  AKSequencerMidi.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/10/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKSequencer{
    
    /// Set the midi output for all tracks
    public func setGlobalMidiOutput(midiEndpoint: MIDIEndpointRef) {
        if isAvSeq {
            for track in avSeq.tracks{
                track.destinationMIDIEndpoint = midiEndpoint
            }
        } else {
            for track in tracks{
                track.setMidiOutput(midiEndpoint)
            }
        }
    }
    
}