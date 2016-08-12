//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Stereo Booster
///
/// - Parameters:
///   - input: Input node to process
///   - gain: Boosting. A
///
public class AKBooster: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKBoosterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var gainParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }
    
    private var lastKnownGain: Double = 1.0
    
    /// Amplification Factor
    public var gain: Double = 1 {
        willSet {
            if gain != newValue {
                if internalAU!.isSetUp() {
                    gainParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.gain = Float(newValue)
                }
            }
        }
    }

    
    /// Amplification Factor in db
    public var dB: Double {
        set {
            gain  = pow(10.0, Double(newValue / 20))
        }
        get {
            return 20.0 * log10(gain)
        }
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this gainner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - gain: Boosting. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: AKNode,
        gain: Double = 0) {

        self.gain = gain

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x70616e32 /*'gain2'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKBoosterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKBooster",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKBoosterAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        gainParameter   = tree.valueForKey("gain")   as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.gainParameter!.address {
                    self.gain = Double(value)
                }
            }
        }
        internalAU?.gain = Float(gain)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            gain = lastKnownGain
        }
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownGain = gain
            gain = 1
        }
    }
}
