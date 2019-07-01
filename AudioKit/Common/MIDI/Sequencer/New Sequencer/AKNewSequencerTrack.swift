//
//  AKNewSequencer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/31/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

/// Audio player that loads a sample into memory
open class AKNewSequencerTrack: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKNewSequencerTrackAudioUnit

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "nseq")

    // MARK: - Properties
    public var loopEnabled: Bool {
        set {
            if internalAU?.isLooping() != newValue {
                internalAU?.toggleLooping()
            }
        }
        get {
            return internalAU?.isLooping() ?? false
        }
    }

    public static let defaultStartPoint = 0.0
    public static let startPointRange = 0.0 ... 20_000.0

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var startPointParameter: AUParameter?
    public var targetNode: AKNode?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    private var startPoint: Sample = 0
    public var lengthInBeats: Double = 4.0
    public var tempo: Double = 120
    public var loopCount: Int = 0
    public var isPlaying: Bool = false
    public var maximumPlayCount: Int = 0
    public var beatTime: Double = 0

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
    public func addNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: Int = 0, beat: Double, duration: Double) {
        var noteOffPosition: Double = (beat + duration);
        while (noteOffPosition >= lengthInBeats && lengthInBeats != 0) {
            noteOffPosition -= lengthInBeats;
        }
        addMIDIEvent(status: AKMIDIStatus(type: .noteOn, channel: MIDIChannel(channel)), data1: noteNumber, data2: velocity, beat: beat)
        addMIDIEvent(status: AKMIDIStatus(type: .noteOff, channel: MIDIChannel(channel)), data1: noteNumber, data2: velocity, beat: noteOffPosition)
    }
    public func addMIDIEvent(status: AKMIDIStatus, data1: UInt8, data2: UInt8, beat: Double) {
        internalAU?.addMIDIEvent(status.byte, data1: data1, data2: data2, beat: beat)
    }
    
    public func clear() {
        internalAU?.clear()
    }
}
