//
//  AKBandRejectButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKBandRejectButterworthFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBandRejectButterworthFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btbr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var bandwidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {

            internalAU?.rampTime = newValue
        }
    }

    /// Center frequency. (in Hertz)
    open dynamic var centerFrequency: Double = 3_000.0 {
        willSet {
            if centerFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        centerFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.centerFrequency = Float(newValue)
                }
            }
        }
    }
    /// Bandwidth. (in Hertz)
    open dynamic var bandwidth: Double = 2_000.0 {
        willSet {
            if bandwidth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        bandwidthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.bandwidth = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
        _ input: AKNode?,
        centerFrequency: Double = 3_000.0,
        bandwidth: Double = 2_000.0) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        centerFrequencyParameter = tree["centerFrequency"]
        bandwidthParameter = tree["bandwidth"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.centerFrequency = Float(centerFrequency)
        internalAU?.bandwidth = Float(bandwidth)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
