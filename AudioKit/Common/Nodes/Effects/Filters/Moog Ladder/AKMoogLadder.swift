//
//  AKMoogLadder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Moog Ladder is an new digital implementation of the Moog ladder filter based
/// on the work of Antti Huovilainen, described in the paper "Non-Linear Digital
/// Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of
/// Napoli). This implementation is probably a more accurate digital
/// representation of the original analogue filter.
///
open class AKMoogLadder: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKMoogLadderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "mgld")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange = 0.0 ... 2.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency = 1_000.0

    /// Initial value for Resonance
    public static let defaultResonance = 0.5

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Filter cutoff frequency.
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

    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
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
    ///   - cutoffFrequency: Filter cutoff frequency.
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance
        ) {

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]

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
