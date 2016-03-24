//
//  AKBandRejectButterworthFilter.swift
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
/// - parameter centerFrequency: Center frequency. (in Hertz)
/// - parameter bandwidth: Bandwidth. (in Hertz)
///
public class AKBandRejectButterworthFilter: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKBandRejectButterworthFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var centerFrequencyParameter: AUParameter?
    private var bandwidthParameter: AUParameter?
    
    /// Inertia represents the speed at which parameters are allowed to change
    public var inertia: Double = 0.0002 {
        willSet(newValue) {
            if inertia != newValue {
                internalAU?.inertia = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Center frequency. (in Hertz)
    public var centerFrequency: Double = 3000 {
        willSet(newValue) {
            if centerFrequency != newValue {
                centerFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Bandwidth. (in Hertz)
    public var bandwidth: Double = 2000 {
        willSet(newValue) {
            if bandwidth != newValue {
                bandwidthParameter?.setValue(Float(newValue), originator: token!)
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
    /// - parameter centerFrequency: Center frequency. (in Hertz)
    /// - parameter bandwidth: Bandwidth. (in Hertz)
    ///
    public init(
        _ input: AKNode,
        centerFrequency: Double = 3000,
        bandwidth: Double = 2000) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x62746272 /*'btbr'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKBandRejectButterworthFilterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKBandRejectButterworthFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKBandRejectButterworthFilterAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        centerFrequencyParameter = tree.valueForKey("centerFrequency") as? AUParameter
        bandwidthParameter       = tree.valueForKey("bandwidth")       as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.centerFrequencyParameter!.address {
                    self.centerFrequency = Double(value)
                } else if address == self.bandwidthParameter!.address {
                    self.bandwidth = Double(value)
                }
            }
        }
        centerFrequencyParameter?.setValue(Float(centerFrequency), originator: token!)
        bandwidthParameter?.setValue(Float(bandwidth), originator: token!)
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
