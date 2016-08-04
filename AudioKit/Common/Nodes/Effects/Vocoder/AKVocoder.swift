//
//  AKVocoder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// 16-band channel vocoder
///
/// - parameter input: Input node to process
/// - parameter attackTime: Attack time (seconds)
/// - parameter releaseTime: Release time (seconds)
/// - parameter bandwidthRatio: Coeffecient to adjust the bandwidth of each band
///
public class AKVocoder: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKVocoderAudioUnit?
    internal var token: AUParameterObserverToken?

    private var attackTimeParameter: AUParameter?
    private var releaseTimeParameter: AUParameter?
    private var bandwidthRatioParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Attack time (seconds)
    public var attackTime: Double = 0.1 {
        willSet {
            if attackTime != newValue {
                if internalAU!.isSetUp() {
                    attackTimeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.attackTime = Float(newValue)
                }
            }
        }
    }
    /// Release time (seconds)
    public var releaseTime: Double = 0.1 {
        willSet {
            if releaseTime != newValue {
                if internalAU!.isSetUp() {
                    releaseTimeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.releaseTime = Float(newValue)
                }
            }
        }
    }
    /// Coeffecient to adjust the bandwidth of each band
    public var bandwidthRatio: Double = 0.5 {
        willSet {
            if bandwidthRatio != newValue {
                if internalAU!.isSetUp() {
                    bandwidthRatioParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.bandwidthRatio = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this vocoder node
    ///
    /// - parameter input: Input node to process, also known as carrier
    /// - parameter excitationSignal: Also known as modulator.
    /// - parameter attackTime: Attack time (seconds)
    /// - parameter releaseTime: Release time (seconds)
    /// - parameter bandwidthRatio: Coeffecient to adjust the bandwidth of each band
    ///
    public init(
        _ input: AKNode,
        excitationSignal: AKNode,
        attackTime: Double = 0.1,
        releaseTime: Double = 0.1,
        bandwidthRatio: Double = 0.5) {

        self.attackTime = attackTime
        self.releaseTime = releaseTime
        self.bandwidthRatio = bandwidthRatio

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x76636472 /*'vcdr'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKVocoderAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKVocoder",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKVocoderAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            
            excitationSignal.connectionPoints.append(AVAudioConnectionPoint(node: self.avAudioNode, bus: 1))
            AudioKit.engine.connect(excitationSignal.avAudioNode, toConnectionPoints: excitationSignal.connectionPoints, fromBus: 0, format: nil)
        }

        guard let tree = internalAU?.parameterTree else { return }

        attackTimeParameter       = tree.valueForKey("attackTime")       as? AUParameter
        releaseTimeParameter      = tree.valueForKey("releaseTime")      as? AUParameter
        bandwidthRatioParameter   = tree.valueForKey("bandwidthRatio")   as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.attackTimeParameter!.address {
                    self.attackTime = Double(value)
                } else if address == self.releaseTimeParameter!.address {
                    self.releaseTime = Double(value)
                } else if address == self.bandwidthRatioParameter!.address {
                    self.bandwidthRatio = Double(value)
                }
            }
        }

        internalAU?.attackTime = Float(attackTime)
        internalAU?.releaseTime = Float(releaseTime)
        internalAU?.bandwidthRatio = Float(bandwidthRatio)
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
