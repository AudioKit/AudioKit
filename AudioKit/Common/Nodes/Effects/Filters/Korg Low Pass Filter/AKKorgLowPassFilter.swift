//
//  AKKorgLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Analogue model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var saturationParameter: AUParameter?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange = 0.0 ... 22_050.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange = 0.0 ... 2.0

    /// Lower and upper bounds for Saturation
    public static let saturationRange = 0.0 ... 10.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency = 1_000.0

    /// Initial value for Resonance
    public static let defaultResonance = 1.0

    /// Initial value for Saturation
    public static let defaultSaturation = 0.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Filter cutoff
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

    /// Filter resonance (should be between 0-2)
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

    /// Filter saturation.
    @objc open dynamic var saturation: Double = defaultSaturation {
        willSet {
            guard saturation != newValue else { return }
            if internalAU?.isSetUp == true {
                saturationParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.saturation, value: newValue)
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
    ///   - cutoffFrequency: Filter cutoff
    ///   - resonance: Filter resonance (should be between 0-2)
    ///   - saturation: Filter saturation.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance,
        saturation: Double = defaultSaturation
        ) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.saturation = saturation

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]
        saturationParameter = tree["saturation"]

        internalAU?.setParameterImmediately(.cutoffFrequency, value: cutoffFrequency)
        internalAU?.setParameterImmediately(.resonance, value: resonance)
        internalAU?.setParameterImmediately(.saturation, value: saturation)
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
