//
//  AKBandRejectButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKBandRejectButterworthFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBandRejectButterworthFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "btbr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var bandwidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
        
            internalAU?.rampTime = newValue
        }
    }

    /// Center frequency. (in Hertz)
    open var centerFrequency: Double = 3000.0 {
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
    /// Bandwidth. (in Hertz)
    open var bandwidth: Double = 2000.0 {
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
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: Bandwidth. (in Hertz)
    ///
    public init(
        _ input: AKNode,
        centerFrequency: Double = 3000.0,
        bandwidth: Double = 2000.0) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else { return }

        centerFrequencyParameter = tree["centerFrequency"]
        bandwidthParameter       = tree["bandwidth"]

        token = tree.token (byAddingParameterObserver: { [weak self]
            address, value in

            DispatchQueue.main.async {
                if address == self?.centerFrequencyParameter!.address {
                    self?.centerFrequency = Double(value)
                } else if address == self?.bandwidthParameter!.address {
                    self?.bandwidth = Double(value)
                }
            }
        })

        internalAU?.centerFrequency = Float(centerFrequency)
        internalAU?.bandwidth = Float(bandwidth)
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
