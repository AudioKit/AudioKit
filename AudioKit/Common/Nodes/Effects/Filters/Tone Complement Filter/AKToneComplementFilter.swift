//
//  AKToneComplementFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// A complement to the AKLowPassFilter.
///
/// - Parameters:
///   - input: Input node to process
///   - halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
///
open class AKToneComplementFilter: AKNode, AKPlayable {

    // MARK: - Properties

    internal var internalAU: AKToneComplementFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    open var halfPowerPoint: Double = 1000.0 {
        willSet {
            if halfPowerPoint != newValue {
                if internalAU!.isSetUp() {
                    halfPowerPointParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.halfPowerPoint = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///
    public init(
        _ input: AKNode,
        halfPowerPoint: Double = 1000.0) {

        self.halfPowerPoint = halfPowerPoint

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = fourCC("aton")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKToneComplementFilterAudioUnit.self,
            as: description,
            name: "Local AKToneComplementFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKToneComplementFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        halfPowerPointParameter = tree.value(forKey: "halfPowerPoint") as? AUParameter

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.halfPowerPointParameter!.address {
                    self.halfPowerPoint = Double(value)
                }
            }
        })

        internalAU?.halfPowerPoint = Float(halfPowerPoint)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
