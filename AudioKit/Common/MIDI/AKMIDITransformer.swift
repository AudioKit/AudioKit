//
//  AKMIDITransformer.swift
//  AudioKit For macOS
//
//  Created by Eric on 7/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

public protocol AKMIDITransformer {
    
    func transform(eventList:[AKMIDIEvent]) -> [AKMIDIEvent]
}

/// Default transformer function
public extension AKMIDITransformer {
    func transform(eventList:[AKMIDIEvent]) -> [AKMIDIEvent] {
        AKLog("MIDI Transformer called")
        return eventList;
    }
}

