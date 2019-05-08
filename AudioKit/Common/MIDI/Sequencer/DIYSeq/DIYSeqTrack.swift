//
//  DIYSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

/// Audio player that loads a sample into memory
open class DIYSeqTrack: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKDIYSeqEngine

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "diys")

    // MARK: - Properties
    public var loopEnabled: Bool {
        set {
            internalAU?.loopEnabled = newValue
        }
        get {
            return internalAU?.loopEnabled ?? false
        }
    }

    public var isPlaying: Bool {
        guard engine != nil else { return false }
        return engine.isPlaying
    }

    public var currentPosition: Double {
        guard engine != nil else { return 0.0 }
        return engine.currentPosition
    }

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var startPointParameter: AUParameter?
    public var targetNode: AKNode?
    private var engine: AKDIYSeqEngine!

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    private var startPoint: Sample = 0
    public var lengthInBeats: Double = 4.0
    public var tempo: Double {
        get {
            return internalAU?.tempo ?? 0
        }
        set {
            internalAU?.tempo = newValue
        }
    }
    public var maximumPlayCount: Double {
        get {
            return internalAU?.maximumPlayCount ?? 0
        }
        set {
            internalAU?.maximumPlayCount = maximumPlayCount
        }
    }

    // MARK: - Initialization
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

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        startPointParameter = tree["startPoint"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            if self == nil {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        AudioKit.internalConnections.append(self)
    }

    @objc public convenience init(targetNode: AKNode) {
        self.init()
        setTarget(node: targetNode)
    }

    public func setTarget(node: AKNode) {
        targetNode = node
        internalAU?.setTarget(targetNode?.avAudioUnit?.audioUnit)
    }

    public func play() {
        internalAU?.start()
    }
    public func stop() {
        internalAU?.stop()
    }
    public func rewind() {
        internalAU?.rewind()
    }
    public func seek(to seekPosition: Double) {
        internalAU?.seek(to: seekPosition)
    }

    open func add(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 127, channel: MIDIChannel = 0,
                  position: Double, duration: Double) {
        var noteOffPosition: Double = (position + duration);
        while (noteOffPosition >= lengthInBeats && lengthInBeats != 0) {
            noteOffPosition -= lengthInBeats;
        }
        add(status: AKMIDIStatus(type: .noteOn, channel: MIDIChannel(channel)),
            data1: noteNumber, data2: velocity, position: position)
        add(status: AKMIDIStatus(type: .noteOff, channel: MIDIChannel(channel)),
            data1: noteNumber, data2: velocity, position: noteOffPosition)
    }

    open func add(status: AKMIDIStatus, data1: UInt8, data2: UInt8, position: Double) {
        internalAU?.addMIDIEvent(status.byte, data1: data1, data2: data2, beat: position)
    }

    open func add(event: AKMIDIEvent, position: Double) {
        if let status = event.status, event.data.count > 2 {
            add(status: status, data1: event.data[1], data2: event.data[2], position: position)
        }
    }
    
    public func clear() {
        internalAU?.clear()
    }
}
