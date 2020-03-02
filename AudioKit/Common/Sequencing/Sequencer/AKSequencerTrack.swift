//
//  AKSequencerTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

/// Audio player that loads a sample into memory
open class AKSequencerTrack: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKSequencerEngine

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "sqcr")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    public var targetNode: AKNode?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet { internalAU?.rampDuration = newValue }
    }

    /// Length of the track in beats
    public var length: Double {
        get { return internalAU?.length ?? 0 }
        set { internalAU?.length = newValue }
    }

    /// Speed of the track in beats per minute
    public var tempo: BPM {
        get { return internalAU?.tempo ?? 0 }
        set { internalAU?.tempo = newValue }
    }

    /// Maximum number of times to play, ie. loop the track
    public var maximumPlayCount: Double {
        get { return internalAU?.maximumPlayCount ?? 0 }
        set { internalAU?.maximumPlayCount = newValue }
    }

    /// Is looping enabled?
    public var loopEnabled: Bool {
        set { internalAU?.loopEnabled = newValue }
        get { return internalAU?.loopEnabled ?? false }
    }

    /// Is the track currently playing?
    public var isPlaying: Bool {
        return internalAU?.isPlaying ?? false
    }

    /// Current position of the track
    public var currentPosition: Double {
        return internalAU?.currentPosition ?? 0
    }

    // MARK: - Initialization

    /// Initialize the track
    @objc public override init() {
        _Self.register()

        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        AKManager.internalConnections.append(self)
    }

    /// Initialize the track with a target node
    @objc public convenience init(targetNode: AKNode) {
        self.init()
        setTarget(node: targetNode)
    }

    /// Set the target node
    public func setTarget(node: AKNode) {
        targetNode = node
        internalAU?.setTarget(targetNode?.avAudioUnit?.audioUnit)
    }

    /// Start the track
    public func play() {
        internalAU?.start()
    }

    /// Start the track from the beginning
    public func playFromStart() {
        seek(to: 0)
        internalAU?.start()
    }

    /// Start the track after a certain delay in beats
    public func playAfterDelay(beats: Double) {
        seek(to: -1 * beats)
        internalAU?.start()
    }

    /// Stop playback
    public func stop() {
        internalAU?.stop()
    }

    /// Set the current position to the start ofthe track
    public func rewind() {
        internalAU?.rewind()
    }

    /// Move to a position in the track
    public func seek(to position: Double) {
        internalAU?.seek(to: position)
    }

    /// Add a MIDI note to the track
    open func add(noteNumber: MIDINoteNumber,
                  velocity: MIDIVelocity = 127,
                  channel: MIDIChannel = 0,
                  position: Double,
                  duration: Double) {
        var noteOffPosition: Double = (position + duration)
        while noteOffPosition >= length && length != 0 {
            noteOffPosition -= length
        }
        internalAU?.addMIDINote(noteNumber,
                                velocity: velocity,
                                beat: position,
                                duration: duration)
    }

    /// Add MIDI data to the track as an event
    open func add(status: AKMIDIStatus, data1: UInt8, data2: UInt8, position: Double) {
        internalAU?.addMIDIEvent(status.byte, data1: data1, data2: data2, beat: position)
    }

    /// Add a MIDI event to the track at a specific position
    open func add(event: AKMIDIEvent, position: Double) {
        if let status = event.status, event.data.count > 2 {
            add(status: status, data1: event.data[1], data2: event.data[2], position: position)
        }
    }

    open func removeEvent(at position: Double) {
        internalAU?.removeEvent(position)
    }

    open func removeNote(at position: Double) {
        internalAU?.removeNote(position)
    }

    /// Remove the notes in the track
    open func clear() {
        internalAU?.clear()
    }

    /// Stop playing all the notes current in the "now playing" array.
    open func stopPlayingNotes() {
        internalAU?.stopPlayingNotes()
    }
}
