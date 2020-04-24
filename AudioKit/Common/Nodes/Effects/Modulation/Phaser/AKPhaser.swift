//
//  AKPhaser.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
open class AKPhaser: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPhaserAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Notch Minimum Frequency
    public static let notchMinimumFrequencyRange: ClosedRange<Double> = 20 ... 5000

    /// Lower and upper bounds for Notch Maximum Frequency
    public static let notchMaximumFrequencyRange: ClosedRange<Double> = 20 ... 10000

    /// Lower and upper bounds for Notch Width
    public static let notchWidthRange: ClosedRange<Double> = 10 ... 5000

    /// Lower and upper bounds for Notch Frequency
    public static let notchFrequencyRange: ClosedRange<Double> = 1.1 ... 4.0

    /// Lower and upper bounds for Vibrato Mode
    public static let vibratoModeRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Depth
    public static let depthRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Inverted
    public static let invertedRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Lfo Bpm
    public static let lfoBPMRange: ClosedRange<Double> = 24 ... 360

    /// Initial value for Notch Minimum Frequency
    public static let defaultNotchMinimumFrequency: Double = 100

    /// Initial value for Notch Maximum Frequency
    public static let defaultNotchMaximumFrequency: Double = 800

    /// Initial value for Notch Width
    public static let defaultNotchWidth: Double = 1000

    /// Initial value for Notch Frequency
    public static let defaultNotchFrequency: Double = 1.5

    /// Initial value for Vibrato Mode
    public static let defaultVibratoMode: Double = 1

    /// Initial value for Depth
    public static let defaultDepth: Double = 1

    /// Initial value for Feedback
    public static let defaultFeedback: Double = 0

    /// Initial value for Inverted
    public static let defaultInverted: Double = 0

    /// Initial value for Lfo Bpm
    public static let defaultLfoBPM: Double = 30

    /// Notch Minimum Frequency
    open var notchMinimumFrequency: Double = defaultNotchMinimumFrequency {
        willSet {
            let clampedValue = AKPhaser.notchMinimumFrequencyRange.clamp(newValue)
            guard notchMinimumFrequency != clampedValue else { return }
            internalAU?.notchMinimumFrequency.value = AUValue(clampedValue)
        }
    }

    /// Notch Maximum Frequency
    open var notchMaximumFrequency: Double = defaultNotchMaximumFrequency {
        willSet {
            let clampedValue = AKPhaser.notchMaximumFrequencyRange.clamp(newValue)
            guard notchMaximumFrequency != clampedValue else { return }
            internalAU?.notchMaximumFrequency.value = AUValue(clampedValue)
        }
    }

    /// Between 10 and 5000
    open var notchWidth: Double = defaultNotchWidth {
        willSet {
            let clampedValue = AKPhaser.notchWidthRange.clamp(newValue)
            guard notchWidth != clampedValue else { return }
            internalAU?.notchWidth.value = AUValue(clampedValue)
        }
    }

    /// Between 1.1 and 4
    open var notchFrequency: Double = defaultNotchFrequency {
        willSet {
            let clampedValue = AKPhaser.notchFrequencyRange.clamp(newValue)
            guard notchFrequency != clampedValue else { return }
            internalAU?.notchFrequency.value = AUValue(clampedValue)
        }
    }

    /// Direct or Vibrato (default)
    open var vibratoMode: Double = defaultVibratoMode {
        willSet {
            let clampedValue = AKPhaser.vibratoModeRange.clamp(newValue)
            guard vibratoMode != clampedValue else { return }
            internalAU?.vibratoMode.value = AUValue(clampedValue)
        }
    }

    /// Between 0 and 1
    open var depth: Double = defaultDepth {
        willSet {
            let clampedValue = AKPhaser.depthRange.clamp(newValue)
            guard depth != clampedValue else { return }
            internalAU?.depth.value = AUValue(clampedValue)
        }
    }

    /// Between 0 and 1
    open var feedback: Double = defaultFeedback {
        willSet {
            let clampedValue = AKPhaser.feedbackRange.clamp(newValue)
            guard feedback != clampedValue else { return }
            internalAU?.feedback.value = AUValue(clampedValue)
        }
    }

    /// 1 or 0
    open var inverted: Double = defaultInverted {
        willSet {
            let clampedValue = AKPhaser.invertedRange.clamp(newValue)
            guard inverted != clampedValue else { return }
            internalAU?.inverted.value = AUValue(clampedValue)
        }
    }

    /// Between 24 and 360
    open var lfoBPM: Double = defaultLfoBPM {
        willSet {
            let clampedValue = AKPhaser.lfoBPMRange.clamp(newValue)
            guard lfoBPM != clampedValue else { return }
            internalAU?.lfoBPM.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this phaser node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - notchMinimumFrequency: Notch Minimum Frequency
    ///   - notchMaximumFrequency: Notch Maximum Frequency
    ///   - notchWidth: Between 10 and 5000
    ///   - notchFrequency: Between 1.1 and 4
    ///   - vibratoMode: Direct or Vibrato (default)
    ///   - depth: Between 0 and 1
    ///   - feedback: Between 0 and 1
    ///   - inverted: 1 or 0
    ///   - lfoBPM: Between 24 and 360
    ///
    public init(
        _ input: AKNode? = nil,
        notchMinimumFrequency: Double = defaultNotchMinimumFrequency,
        notchMaximumFrequency: Double = defaultNotchMaximumFrequency,
        notchWidth: Double = defaultNotchWidth,
        notchFrequency: Double = defaultNotchFrequency,
        vibratoMode: Double = defaultVibratoMode,
        depth: Double = defaultDepth,
        feedback: Double = defaultFeedback,
        inverted: Double = defaultInverted,
        lfoBPM: Double = defaultLfoBPM
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.notchMinimumFrequency = notchMinimumFrequency
            self.notchMaximumFrequency = notchMaximumFrequency
            self.notchWidth = notchWidth
            self.notchFrequency = notchFrequency
            self.vibratoMode = vibratoMode
            self.depth = depth
            self.feedback = feedback
            self.inverted = inverted
            self.lfoBPM = lfoBPM
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
