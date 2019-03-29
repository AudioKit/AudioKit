//
//  AKSequencerTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/18/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSequencerTrack {

    var engine: AKSequencerTrackEngine!
    var _events = [AKMIDIEvent]()
    public var events: [AKMIDIEvent] { return _events }
    public var trackID: Int = 0 { didSet { engine.trackIndex = Int32(trackID) } }
    public var lengthInBeats: Double = 4 { didSet { engine.setLengthInBeats(lengthInBeats, at: AVAudioTime.now()) } }
    public var tempo: Double = 120 {
        didSet {
            let now = AVAudioTime(hostTime: mach_absolute_time())
            engine.setTempo(tempo, at: now)
        }

    }

    public var currentPosition: AKDuration {
        var position = AKDuration(beats: 0)
        position = AKDuration(beats: engine.beatTime, tempo: engine.tempo)
        return position
    }

    public var loopEnabled: Bool = true { didSet { engine.maximumPlayCount = loopEnabled ? 0 : 1 } }
    public var loopCount: UInt = 0 { didSet { engine.maximumPlayCount = uint(loopCount) } }
    public var isPlaying: Bool { return engine.isPlaying }
    public var targetNode: AKNode
    public var loopCallback: AKCallback = { }{
        didSet {
            engine.loopCallback = loopCallback
        }
    }
    public var eventCallback: AKMIDICallback = {status, data1, data2 in }{
        didSet {
            engine.eventCallback = eventCallback
        }
    }

    public init(_ node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(node, index: Int32(index))
        targetNode = node
    }

    public init(midiPort: MIDIPortRef, midiEndpoint: MIDIEndpointRef, node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(midiPort, midiEndpoint: midiEndpoint, node: node, index: Int32(index))
        targetNode = node
    }

    open func add(event: AKMIDIEvent, at position: Double) {
        if let status = event.status {
            let statusByte = status.byte
            let data1 = event.data.count > 1 ? event.data[1] : 0
            let data2 = event.data.count > 2 ? event.data[2] : 0
            engine.addMIDIEvent(statusByte, data1: data1, data2: data2, at: position)
        }
    }

    open func add(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, at: Double, duration: Double) {
        engine.addNote(noteNumber, velocity: velocity, at: at, duration: duration)
    }

    public func playOnNextBeat(at beatTime: Double = 0) {
        engine.setBeatTime(-1.0 * beatTime, at: nil)
        engine.play()
    }

    open func add(controller: UInt8, value: UInt8, at: Double, channel: UInt8) {
        let status = AKMIDIStatus.init(type: .controllerChange, channel: channel)
        engine.addMIDIEvent(status.byte, data1: controller, data2: value, at: at)
    }

    open func play() {
        engine.setBeatTime(0, at: nil)
        engine.play()
    }

    open func stop() {
        engine.stop()
        engine.setBeatTime(0, at: nil)
    }

    open func seek(to time: Double, at position: AVAudioTime? = nil) {
        engine.setBeatTime(time, at: position)
    }

    open func clear() {
        engine.clear()
    }

    open func stopAllNotes() {
        engine.stopAllNotes()
    }

    open func stopAfterCurrentNotes() {
        engine.stopAfterCurrentNotes()
    }

    open func debugEvents() {
        engine.debugEvents()
    }

}
