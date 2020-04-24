//
//  AKAmplitudeEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// Triggerable classic ADSR envelope
///
open class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAmplitudeEnvelopeAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange: ClosedRange<Double> = 0 ... 99

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange: ClosedRange<Double> = 0 ... 99

    /// Lower and upper bounds for Sustain Level
    public static let sustainLevelRange: ClosedRange<Double> = 0 ... 99

    /// Lower and upper bounds for Release Duration
    public static let releaseDurationRange: ClosedRange<Double> = 0 ... 99

    /// Initial value for Attack Duration
    public static let defaultAttackDuration: Double = 0.1

    /// Initial value for Decay Duration
    public static let defaultDecayDuration: Double = 0.1

    /// Initial value for Sustain Level
    public static let defaultSustainLevel: Double = 1.0

    /// Initial value for Release Duration
    public static let defaultReleaseDuration: Double = 0.1

    /// Attack time
    open var attackDuration: Double = defaultAttackDuration {
        willSet {
            let clampedValue = AKAmplitudeEnvelope.attackDurationRange.clamp(newValue)
            guard attackDuration != clampedValue else { return }
            internalAU?.attackDuration.value = AUValue(clampedValue)
        }
    }

    /// Decay time
    open var decayDuration: Double = defaultDecayDuration {
        willSet {
            let clampedValue = AKAmplitudeEnvelope.decayDurationRange.clamp(newValue)
            guard decayDuration != clampedValue else { return }
            internalAU?.decayDuration.value = AUValue(clampedValue)
        }
    }

    /// Sustain Level
    open var sustainLevel: Double = defaultSustainLevel {
        willSet {
            let clampedValue = AKAmplitudeEnvelope.sustainLevelRange.clamp(newValue)
            guard sustainLevel != clampedValue else { return }
            internalAU?.sustainLevel.value = AUValue(clampedValue)
        }
    }

    /// Release time
    open var releaseDuration: Double = defaultReleaseDuration {
        willSet {
            let clampedValue = AKAmplitudeEnvelope.releaseDurationRange.clamp(newValue)
            guard releaseDuration != clampedValue else { return }
            internalAU?.releaseDuration.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this envelope node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackDuration: Attack time
    ///   - decayDuration: Decay time
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release time
    ///
    public init(
        _ input: AKNode? = nil,
        attackDuration: Double = defaultAttackDuration,
        decayDuration: Double = defaultDecayDuration,
        sustainLevel: Double = defaultSustainLevel,
        releaseDuration: Double = defaultReleaseDuration
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.attackDuration = attackDuration
            self.decayDuration = decayDuration
            self.sustainLevel = sustainLevel
            self.releaseDuration = releaseDuration
        }
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
