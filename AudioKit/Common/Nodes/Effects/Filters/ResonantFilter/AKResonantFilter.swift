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
open class AKResonantFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKResonantFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "resn")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var bandwidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Center frequency of the filter, or frequency position of the peak response.
    open var frequency: Double = 4000.0 {
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
    open var bandwidth: Double = 1000.0 {
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

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree["frequency"]
        bandwidthParameter = tree["bandwidth"]

        token = tree.token (byAddingParameterObserver: { [weak self]
            address, value in

            DispatchQueue.main.async {
                if address == self?.frequencyParameter!.address {
                    self?.frequency = Double(value)
                } else if address == self?.bandwidthParameter!.address {
                    self?.bandwidth = Double(value)
                }
            }
        })

        internalAU?.frequency = Float(frequency)
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
