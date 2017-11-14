//
//  AKPeakingParametricEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
open class AKPeakingParametricEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPeakingParametricEqualizerFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "peq0")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var gainParameter: AUParameter?
    fileprivate var qParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Center frequency.
    @objc open dynamic var centerFrequency: Double = 1_000 {
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
    /// Amount at which the center frequency value shall be increased or decreased. A value of 1 is a flat response.
    @objc open dynamic var gain: Double = 1.0 {
        willSet {
            if gain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        gainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.gain = Float(newValue)
                }
            }
        }
    }
    /// Q of the filter. sqrt(0.5) is no resonance.
    @objc open dynamic var q: Double = 0.707 {
        willSet {
            if q != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        qParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.q = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency.
    ///   - gain: Amount the center frequency value shall be increased or decreased. A value of 1 is a flat response.
    ///   - q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = 1_000,
        gain: Double = 1.0,
        q: Double = 0.707) {

        self.centerFrequency = centerFrequency
        self.gain = gain
        self.q = q

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

        centerFrequencyParameter = tree["centerFrequency"]
        gainParameter = tree["gain"]
        qParameter = tree["q"]

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

        internalAU?.centerFrequency = Float(centerFrequency)
        internalAU?.gain = Float(gain)
        internalAU?.q = Float(q)
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
