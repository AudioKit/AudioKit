//
//  AKMIDINoteData.swift
//  AudioKit
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Struct holding revelant data for AKMusicTrack note events
public struct AKMIDINoteData: CustomStringConvertible, Equatable {
    public var noteNumber: MIDINoteNumber
    public var velocity: MIDIVelocity
    public var channel: MIDIChannel
    public var duration: AKDuration
    public var position: AKDuration

    public init(noteNumber: MIDINoteNumber,
                velocity: MIDIVelocity,
                channel: MIDIChannel,
                duration: AKDuration,
                position: AKDuration) {
        self.noteNumber = noteNumber
        self.velocity = velocity
        self.channel = channel
        self.duration = duration
        self.position = position
    }

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
