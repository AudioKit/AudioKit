//
//  AKKorgLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Analog model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var saturationParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Filter cutoff
    @objc open dynamic var cutoffFrequency: Double = 1_000.0 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        cutoffFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }
    /// Filter resonance (should be between 0-2)
    @objc open dynamic var resonance: Double = 1.0 {
        willSet {
            if resonance != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        resonanceParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.resonance = Float(newValue)
                }
            }
        }
    }
    /// Filter saturation.
    @objc open dynamic var saturation: Double = 0.0 {
        willSet {
            if saturation != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        saturationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.saturation = Float(newValue)
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
    /// - parameter cutoffFrequency: Filter cutoff
    /// - parameter resonance: Filter resonance (should be between 0-2)
    /// - parameter saturation: Filter saturation.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = 1_000.0,
        resonance: Double = 1.0,
        saturation: Double = 0.0) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.saturation = saturation

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]
        saturationParameter = tree["saturation"]

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

        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
        internalAU?.saturation = Float(saturation)
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
