//
//  SequencerEvent.swift
//  SequencerExtender
//
//  Created by Jeff Cooper on 11/26/18.
//  Copyright © 2018 Southern Works. All rights reserved.
//

import Foundation

public struct SequenceNoteEvent: SequenceEvent {

    public init(event: AKMIDIEvent, position: Double) {
        self.event = event
        self.position = position
    }

    public var event: AKMIDIEvent
    public var position: Double {
        get {
            return basePosition + positionModifier
        }
        set {
            basePosition = newValue
            positionModifier = 0
        }
    }
    public var basePosition: Double = 0
    public var positionModifier: Double = 0
    public var baseNoteNumber: MIDINoteNumber {
        return data[1]
    }
    public var noteNumber: MIDINoteNumber {
        get {
            return baseNoteNumber + noteModifier
        }
        set {
            event.internalData[1] = newValue
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
            event.internalData[2] = newValue
            velocityModifier = 0
        }
    }
    public var velocityModifier: MIDIVelocity = 0
    public var channel: MIDIChannel {
        return status!.channel
    }
    mutating func modifyPosition(by amount: Double){
        positionModifier = amount
    }
}

public protocol SequenceEvent {
    var position: Double { get set }
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
