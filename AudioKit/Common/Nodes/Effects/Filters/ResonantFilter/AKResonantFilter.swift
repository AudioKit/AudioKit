//
//  AKResonantFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// The output for reson appears to be very hot, so take caution when using this
/// module.
///
open class AKResonantFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKResonantFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "resn")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var bandwidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Center frequency of the filter, or frequency position of the peak response.
    @objc open dynamic var frequency: Double = 4_000.0 {
        willSet {
            if frequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        frequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }
    /// Bandwidth of the filter.
    @objc open dynamic var bandwidth: Double = 1_000.0 {
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
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter frequency: Center frequency of the filter, or frequency position of the peak response.
    /// - parameter bandwidth: Bandwidth of the filter.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        frequency: Double = 4_000.0,
        bandwidth: Double = 1_000.0) {

        self.frequency = frequency
        self.bandwidth = bandwidth

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        bandwidthParameter = tree["bandwidth"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.frequency = Float(frequency)
        internalAU?.bandwidth = Float(bandwidth)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
