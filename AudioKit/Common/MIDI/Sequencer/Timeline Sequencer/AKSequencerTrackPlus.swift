//
//  AKSequencerTrackPlus.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/26/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public class AKSequencerTrackPlus: AKSequencerTrack {
    public var sequenceEvents: [SequenceEvent] = [] {
        didSet {
            updateSequence()
        }
    }

    public func updateSequence() {
        clear()
        for event in sequenceEvents {
            add(event: event.event, at: event.position.beats)
        }
    }
}
