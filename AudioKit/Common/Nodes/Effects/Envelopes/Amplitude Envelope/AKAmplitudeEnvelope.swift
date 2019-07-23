//
//  AKAmplitudeEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Triggerable classic ADSR envelope
///
open class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAmplitudeEnvelopeAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange = 0.0 ... 99.0

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange = 0.0 ... 99.0

    /// Lower and upper bounds for Sustain Level
    public static let sustainLevelRange = 0.0 ... 99.0

    /// Lower and upper bounds for Release Duration
    public static let releaseDurationRange = 0.0 ... 99.0

    /// Initial value for Attack Duration
    public static let defaultAttackDuration = 0.1

    /// Initial value for Decay Duration
    public static let defaultDecayDuration = 0.1

    /// Initial value for Sustain Level
    public static let defaultSustainLevel = 1.0

    /// Initial value for Release Duration
    public static let defaultReleaseDuration = 0.1

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Attack Duration in seconds
    @objc open dynamic var attackDuration: Double = defaultAttackDuration {
        willSet {
            guard attackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                attackDurationParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.attackDuration, value: newValue)
        }
    }

    /// Decay Duration in seconds
    @objc open dynamic var decayDuration: Double = defaultDecayDuration {
        willSet {
            guard decayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                decayDurationParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.decayDuration, value: newValue)
        }
    }

    /// Sustain Level
    @objc open dynamic var sustainLevel: Double = defaultSustainLevel {
        willSet {
            guard sustainLevel != newValue else { return }
            if internalAU?.isSetUp == true {
                sustainLevelParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.sustainLevel, value: newValue)
        }
    }

    /// Release Duration in seconds
    @objc open dynamic var releaseDuration: Double = defaultReleaseDuration {
        willSet {
            guard releaseDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                releaseDurationParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.releaseDuration, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this envelope node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackDuration: Attack Duration in seconds
    ///   - decayDuration: Decay Duration in seconds
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release Duration in seconds
    ///
    @objc public init(
        _ input: AKNode? = nil,
        attackDuration: Double = defaultAttackDuration,
        decayDuration: Double = defaultDecayDuration,
        sustainLevel: Double = defaultSustainLevel,
        releaseDuration: Double = defaultReleaseDuration
        ) {

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration

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

        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]

        internalAU?.setParameterImmediately(.attackDuration, value: attackDuration)
        internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
        internalAU?.setParameterImmediately(.sustainLevel, value: sustainLevel)
        internalAU?.setParameterImmediately(.releaseDuration, value: releaseDuration)
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
