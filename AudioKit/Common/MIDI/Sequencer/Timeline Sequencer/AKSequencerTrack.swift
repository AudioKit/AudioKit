//
//  AKSequencerTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/18/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public class AKSequencerTrack {

    var engine: AKSequencerTrackEngine!
    var _events = [AKMIDIEvent]()
    public var events: [AKMIDIEvent] {  return _events }
    public var trackID: Int = 0 {  didSet { engine.trackIndex = Int32(trackID) } }
    public var lengthInBeats: Double = 4 {  didSet { engine.lengthInBeats = lengthInBeats } }
    public var tempo: Double = 120 {  didSet { engine.tempo = tempo } }
    public var loopEnabled: Bool = true {  didSet { engine.maximumPlayCount = loopEnabled ? 0 : 1 } }
    public var noteOffset: Int = 0 {  didSet { engine.noteOffset = Int32(noteOffset) } }
    public var channelOffset: Int = 0 { didSet { engine.channelOffset = Int32(channelOffset) } }
    public var timeMultiplier: Double = 1 {  didSet { engine.timeMultiplier = timeMultiplier } }
    public var gateMultiplier: Double = 1 {  didSet { engine.gateMultiplier = gateMultiplier } }

    init(_ node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(node, index: Int32(index))
    }

    init(midiPort: MIDIPortRef, midiEndpoint: MIDIEndpointRef, node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(midiPort, midiEndpoint: midiEndpoint, node: node, index: Int32(index))
    }

    public func add(event: AKMIDIEvent, at position: Double) {
        if let status = event.status {
            engine.addMIDIEvent(UInt8(status.rawValue), data1: event.data1, data2: event.data2, at: position)
        }
    }
    public func addNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, at: Double, duration: Double) {
        engine.addNote(noteNumber, velocity: velocity, at: at, duration: duration)
    }

    public func play() {
        engine.play()
    }

    public func stop() {
        engine.stop()
        engine.stopAllNotes()
    }

    public func seek(to time: Double, at position: AVAudioTime? = nil) {
        engine.setBeatTime(time, at: position)
    }
    
    public func clear() {
        engine.clear()
    }

    public func stopAllNotes() {
        engine.stopAllNotes()
    }

}
