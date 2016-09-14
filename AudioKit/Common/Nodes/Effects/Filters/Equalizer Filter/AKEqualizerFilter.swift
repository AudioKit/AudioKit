//
//  AKEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// A 2nd order tunable equalization filter that provides a peak/notch filter
/// for building parametric/graphic equalizers. With gain above 1, there will be
/// a peak at the center frequency with a width dependent on bandwidth. If gain
/// is less than 1, a notch is formed around the center frequency.
///
/// - Parameters:
///   - input: Input node to process
///   - centerFrequency: Center frequency in Hertz
///   - bandwidth: The peak/notch bandwidth in Hertz
///   - gain: The peak/notch gain
///
public class AKEqualizerFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKEqualizerFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var centerFrequencyParameter: AUParameter?
    private var bandwidthParameter: AUParameter?
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

    /// Center frequency. (in Hertz)
    public var centerFrequency: Double = 1000.0 {
        willSet {
            if centerFrequency != newValue {
                if internalAU!.isSetUp() {
                    centerFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.centerFrequency = Float(newValue)
                }
            }
        }
    }
    /// The peak/notch bandwidth in Hertz
    public var bandwidth: Double = 100.0 {
        willSet {
            if bandwidth != newValue {
                if internalAU!.isSetUp() {
                    bandwidthParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.bandwidth = Float(newValue)
                }
            }
        }
    }
    /// The peak/notch gain
    public var gain: Double = 10.0 {
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency in Hertz
    ///   - bandwidth: The peak/notch bandwidth in Hertz
    ///   - gain: The peak/notch gain
    ///
    public init(
        _ input: AKNode,
        centerFrequency: Double = 1000.0,
        bandwidth: Double = 100.0,
        gain: Double = 10.0) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
        self.gain = gain

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6571666c /*'eqfl'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKEqualizerFilterAudioUnit.self,
            as: description,
            name: "Local AKEqualizerFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKEqualizerFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        centerFrequencyParameter = tree.value(forKey: "centerFrequency") as? AUParameter
        bandwidthParameter       = tree.value(forKey: "bandwidth")       as? AUParameter
        gainParameter            = tree.value(forKey: "gain")            as? AUParameter

        token = tree.token(byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.centerFrequencyParameter!.address {
                    self.centerFrequency = Double(value)
                } else if address == self.bandwidthParameter!.address {
                    self.bandwidth = Double(value)
                } else if address == self.gainParameter!.address {
                    self.gain = Double(value)
                }
            }
        })

        internalAU?.centerFrequency = Float(centerFrequency)
        internalAU?.bandwidth = Float(bandwidth)
        internalAU?.gain = Float(gain)
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
