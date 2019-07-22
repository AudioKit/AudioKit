//
//  AKThreePoleLowpassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
open class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKThreePoleLowpassFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var distortionParameter: AUParameter?
    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?

    /// Lower and upper bounds for Distortion
    public static let distortionRange = 0.0 ... 2.0

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange = 0.0 ... 2.0

    /// Initial value for Distortion
    public static let defaultDistortion = 0.5

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency = 1_500.0

    /// Initial value for Resonance
    public static let defaultResonance = 0.5

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    @objc open dynamic var distortion: Double = defaultDistortion {
        willSet {
            guard distortion != newValue else { return }
            if internalAU?.isSetUp == true {
                distortionParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.distortion, value: newValue)
        }
    }

    /// Filter cutoff frequency in Hertz.
    @objc open dynamic var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            guard cutoffFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                cutoffFrequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.cutoffFrequency, value: newValue)
        }
    }

    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    @objc open dynamic var resonance: Double = defaultResonance {
        willSet {
            guard resonance != newValue else { return }
            if internalAU?.isSetUp == true {
                resonanceParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.resonance, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz.
    ///   - resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        distortion: Double = defaultDistortion,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance
        ) {

        self.distortion = distortion
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        distortionParameter = tree["distortion"]
        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]

        internalAU?.setParameterImmediately(.distortion, value: distortion)
        internalAU?.setParameterImmediately(.cutoffFrequency, value: cutoffFrequency)
        internalAU?.setParameterImmediately(.resonance, value: resonance)
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
