//
//  AKMIDINoteData.swift
//  AudioKit
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Struct holding revelant data for AKMusicTrack note events
public struct AKMIDINoteData: CustomStringConvertible {
    public var noteNumber: MIDINoteNumber
    public var velocity: MIDIVelocity
    public var channel: MIDIChannel
    public var duration: AKDuration
    public var position: AKDuration

    public var description: String {
        return """
        note: \(noteNumber)
        velocity: \(velocity)
        chan: \(channel)
        duration: \(duration.beats)
        position \(position.beats)
        """
    }
}
