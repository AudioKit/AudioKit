//
//  SequencerEvent.swift
//  SequencerExtender
//
//  Created by Jeff Cooper on 11/26/18.
//  Copyright © 2018 Southern Works. All rights reserved.
//

import Foundation

public struct SequenceNoteEvent: SequenceEvent {

    public var event: AKMIDIEvent
    public var position: AKDuration {
        get {
            return basePosition + positionModifier
        }
        set {
            basePosition = position
            positionModifier = AKDuration(beats: 0)
        }
    }
    public var basePosition: AKDuration = AKDuration(beats: 0)
    public var positionModifier: AKDuration = AKDuration(beats: 0)
    public var baseDuration: AKDuration = AKDuration(beats: 0)
    public var duration: AKDuration {
        get {
            return baseDuration + durationModifier
        }
        set {
            baseDuration = position
            durationModifier = AKDuration(beats: 0)
        }
    }
    public var durationModifier: AKDuration = AKDuration(beats: 0)
    public var baseNoteNumber: MIDINoteNumber {
        return data[1]
    }
    public var noteNumber: MIDINoteNumber {
        get {
            return baseNoteNumber + noteModifier
        }
        set {
            event.internalData[1] = noteNumber
            noteModifier = 0
        }
    }
    public var noteModifier: MIDINoteNumber = 0
    public var baseVelocity: MIDIVelocity {
        return data[2]
    }
    public var velocity: MIDIVelocity {
        get {
            return baseVelocity + velocityModifier
        }
        set {
            event.internalData[2] = velocity
            velocityModifier = 0
        }
    }
    public var velocityModifier: MIDIVelocity = 0
    public var channel: MIDIChannel {
        return status!.channel!
    }
}

public protocol SequenceEvent {
    var position: AKDuration { get set }
    var duration: AKDuration { get set }
    var event: AKMIDIEvent { get set }
    var status: AKMIDIStatus? { get }
    var data: [MIDIByte] { get }
}

public extension SequenceEvent {
    public var status: AKMIDIStatus? {
        return AKMIDIStatus(byte: data[1])
    }
    public var data: [MIDIByte] {
        return event.internalData
    }
}
