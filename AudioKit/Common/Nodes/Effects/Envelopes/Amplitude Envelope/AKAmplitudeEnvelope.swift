//
//  AKAmplitudeEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Classic ADSR envelope
///
/// - parameter input: Input node to process
/// - parameter attackDuration: Attack time (Default: 0.1)
/// - parameter decayDuration: Decay time (Default: 0.1)
/// - parameter sustainLevel: Sustain Level (Default: 1.0)
/// - parameter releaseDuration: Release time (Default: 0.1)
///
public class AKAmplitudeEnvelope: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKAmplitudeEnvelopeAudioUnit?
    internal var token: AUParameterObserverToken?

    private var attackDurationParameter: AUParameter?
    private var decayDurationParameter: AUParameter?
    private var sustainLevelParameter: AUParameter?
    private var releaseDurationParameter: AUParameter?

    /// Attack time
    public var attackDuration: Double = 0.1 {
        willSet(newValue) {
            if attackDuration != newValue {
                attackDurationParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        willSet(newValue) {
            if decayDuration != newValue {
                decayDurationParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 1.0 {
        willSet(newValue) {
            if sustainLevel != newValue {
                sustainLevelParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.1 {
        willSet(newValue) {
            if releaseDuration != newValue {
                releaseDurationParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this envelope node
    ///
    /// - parameter input: Input node to process
    /// - parameter attackDuration: Attack time (Default: 0.1)
    /// - parameter decayDuration: Decay time (Default: 0.1)
    /// - parameter sustainLevel: Sustain Level (Default: 1.0)
    /// - parameter releaseDuration: Release time (Default: 0.1)
    ///
    public init(
        _ input: AKNode,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1) {

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x61647372 /*'adsr'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKAmplitudeEnvelopeAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKAmplitudeEnvelope",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKAmplitudeEnvelopeAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        attackDurationParameter  = tree.valueForKey("attackDuration")  as? AUParameter
        decayDurationParameter   = tree.valueForKey("decayDuration")   as? AUParameter
        sustainLevelParameter    = tree.valueForKey("sustainLevel")    as? AUParameter
        releaseDurationParameter = tree.valueForKey("releaseDuration") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.attackDurationParameter!.address {
                    self.attackDuration = Double(value)
                } else if address == self.decayDurationParameter!.address {
                    self.decayDuration = Double(value)
                } else if address == self.sustainLevelParameter!.address {
                    self.sustainLevel = Double(value)
                } else if address == self.releaseDurationParameter!.address {
                    self.releaseDuration = Double(value)
                }
            }
        }
        attackDurationParameter?.setValue(Float(attackDuration), originator: token!)
        decayDurationParameter?.setValue(Float(decayDuration), originator: token!)
        sustainLevelParameter?.setValue(Float(sustainLevel), originator: token!)
        releaseDurationParameter?.setValue(Float(releaseDuration), originator: token!)
    }
    
    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }

}
