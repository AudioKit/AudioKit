//
//  AKHighPassButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
/// - parameter input: Input node to process
/// - parameter cutoffFrequency: Cutoff frequency. (in Hertz)
///
public class AKHighPassButterworthFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKHighPassButterworthFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var cutoffFrequencyParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Cutoff frequency. (in Hertz)
    public var cutoffFrequency: Double = 500 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU!.isSetUp() {
                    cutoffFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz)
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 500) {

        self.cutoffFrequency = cutoffFrequency

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x62746870 /*'bthp'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKHighPassButterworthFilterAudioUnit.self,
            as: description,
            name: "Local AKHighPassButterworthFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKHighPassButterworthFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cutoffFrequencyParameter = tree.value(forKey: "cutoffFrequency") as? AUParameter

        token = tree.token {
            address, value in

            DispatchQueue.main.async {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                }
            }
        }
        internalAU?.cutoffFrequency = Float(cutoffFrequency)
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
