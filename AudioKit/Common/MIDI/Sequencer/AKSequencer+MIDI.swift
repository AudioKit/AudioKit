//
//  AKSequencer+MIDI.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKSequencer {
    
    /// Set the midi output for all tracks
    public func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.destinationMIDIEndpoint = midiEndpoint
            }
        } else {
            for track in tracks {
                track.setMIDIOutput(midiEndpoint)
            }
        }
    }
    
}
