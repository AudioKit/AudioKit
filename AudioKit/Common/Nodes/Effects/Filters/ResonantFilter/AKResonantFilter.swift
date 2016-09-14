//
//  AKResonantFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// The output for reson appears to be very hot, so take caution when using this
/// module.
///
/// - parameter input: Input node to process
/// - parameter frequency: Center frequency of the filter, or frequency position of the peak response.
/// - parameter bandwidth: Bandwidth of the filter.
///
public class AKResonantFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKResonantFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var frequencyParameter: AUParameter?
    private var bandwidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Center frequency of the filter, or frequency position of the peak response.
    public var frequency: Double = 4000.0 {
        willSet {
            if frequency != newValue {
                if internalAU!.isSetUp() {
                    frequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }
    /// Bandwidth of the filter.
    public var bandwidth: Double = 1000.0 {
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter frequency: Center frequency of the filter, or frequency position of the peak response.
    /// - parameter bandwidth: Bandwidth of the filter.
    ///
    public init(
        _ input: AKNode,
        frequency: Double = 4000.0,
        bandwidth: Double = 1000.0) {

        self.frequency = frequency
        self.bandwidth = bandwidth

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x7265736e /*'resn'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKResonantFilterAudioUnit.self,
            as: description,
            name: "Local AKResonantFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKResonantFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree.value(forKey: "frequency") as? AUParameter
        bandwidthParameter = tree.value(forKey: "bandwidth") as? AUParameter

        token = tree.token(byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.bandwidthParameter!.address {
                    self.bandwidth = Double(value)
                }
            }
        })

        internalAU?.frequency = Float(frequency)
        internalAU?.bandwidth = Float(bandwidth)
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
