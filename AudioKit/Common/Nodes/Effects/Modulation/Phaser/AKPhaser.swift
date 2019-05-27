//
//  AKPhaser.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
open class AKPhaser: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPhaserAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var notchMinimumFrequencyParameter: AUParameter?
    fileprivate var notchMaximumFrequencyParameter: AUParameter?
    fileprivate var notchWidthParameter: AUParameter?
    fileprivate var notchFrequencyParameter: AUParameter?
    fileprivate var vibratoModeParameter: AUParameter?
    fileprivate var depthParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?
    fileprivate var invertedParameter: AUParameter?
    fileprivate var lfoBPMParameter: AUParameter?

    /// Lower and upper bounds for Notch Minimum Frequency
    public static let notchMinimumFrequencyRange = 20.0 ... 5_000.0

    /// Lower and upper bounds for Notch Maximum Frequency
    public static let notchMaximumFrequencyRange = 20.0 ... 10_000.0

    /// Lower and upper bounds for Notch Width
    public static let notchWidthRange = 10.0 ... 5_000.0

    /// Lower and upper bounds for Notch Frequency
    public static let notchFrequencyRange = 1.1 ... 4.0

    /// Lower and upper bounds for Vibrato Mode
    public static let vibratoModeRange = 0.0 ... 1.0

    /// Lower and upper bounds for Depth
    public static let depthRange = 0.0 ... 1.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange = 0.0 ... 1.0

    /// Lower and upper bounds for Inverted
    public static let invertedRange = 0.0 ... 1.0

    /// Lower and upper bounds for Lfo BPM
    public static let lfoBPMRange = 24.0 ... 360.0

    /// Initial value for Notch Minimum Frequency
    public static let defaultNotchMinimumFrequency = 100.0

    /// Initial value for Notch Maximum Frequency
    public static let defaultNotchMaximumFrequency = 800.0

    /// Initial value for Notch Width
    public static let defaultNotchWidth = 1_000.0

    /// Initial value for Notch Frequency
    public static let defaultNotchFrequency = 1.5

    /// Initial value for Vibrato Mode
    public static let defaultVibratoMode = 1.0

    /// Initial value for Depth
    public static let defaultDepth = 1.0

    /// Initial value for Feedback
    public static let defaultFeedback = 0.0

    /// Initial value for Inverted
    public static let defaultInverted = 0.0

    /// Initial value for Lfo BPM
    public static let defaultLfoBPM = 30.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Notch Minimum Frequency
    @objc open dynamic var notchMinimumFrequency: Double = defaultNotchMinimumFrequency {
        willSet {
            guard notchMinimumFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                notchMinimumFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.notchMinimumFrequency, value: newValue)
        }
    }

    /// Notch Maximum Frequency
    @objc open dynamic var notchMaximumFrequency: Double = defaultNotchMaximumFrequency {
        willSet {
            guard notchMaximumFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                notchMaximumFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.notchMaximumFrequency, value: newValue)
        }
    }

    /// Between 10 and 5000
    @objc open dynamic var notchWidth: Double = defaultNotchWidth {
        willSet {
            guard notchWidth != newValue else { return }
            if internalAU?.isSetUp == true {
                notchWidthParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.notchWidth, value: newValue)
        }
    }

    /// Between 1.1 and 4
    @objc open dynamic var notchFrequency: Double = defaultNotchFrequency {
        willSet {
            guard notchFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                notchFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.notchFrequency, value: newValue)
        }
    }

    /// Direct or Vibrato (default)
    @objc open dynamic var vibratoMode: Double = defaultVibratoMode {
        willSet {
            guard vibratoMode != newValue else { return }
            if internalAU?.isSetUp == true {
                vibratoModeParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.vibratoMode, value: newValue)
        }
    }

    /// Between 0 and 1
    @objc open dynamic var depth: Double = defaultDepth {
        willSet {
            guard depth != newValue else { return }
            if internalAU?.isSetUp == true {
                depthParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.depth, value: newValue)
        }
    }

    /// Between 0 and 1
    @objc open dynamic var feedback: Double = defaultFeedback {
        willSet {
            guard feedback != newValue else { return }
            if internalAU?.isSetUp == true {
                feedbackParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.feedback, value: newValue)
        }
    }

    /// 1 or 0
    @objc open dynamic var inverted: Double = defaultInverted {
        willSet {
            guard inverted != newValue else { return }
            if internalAU?.isSetUp == true {
                invertedParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.inverted, value: newValue)
        }
    }

    /// Between 24 and 360
    @objc open dynamic var lfoBPM: Double = defaultLfoBPM {
        willSet {
            guard lfoBPM != newValue else { return }
            if internalAU?.isSetUp == true {
                lfoBPMParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.lfoBPM, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
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
    @objc public init(
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

        self.notchMinimumFrequency = notchMinimumFrequency
        self.notchMaximumFrequency = notchMaximumFrequency
        self.notchWidth = notchWidth
        self.notchFrequency = notchFrequency
        self.vibratoMode = vibratoMode
        self.depth = depth
        self.feedback = feedback
        self.inverted = inverted
        self.lfoBPM = lfoBPM

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

        notchMinimumFrequencyParameter = tree["notchMinimumFrequency"]
        notchMaximumFrequencyParameter = tree["notchMaximumFrequency"]
        notchWidthParameter = tree["notchWidth"]
        notchFrequencyParameter = tree["notchFrequency"]
        vibratoModeParameter = tree["vibratoMode"]
        depthParameter = tree["depth"]
        feedbackParameter = tree["feedback"]
        invertedParameter = tree["inverted"]
        lfoBPMParameter = tree["lfoBPM"]

        internalAU?.setParameterImmediately(.notchMinimumFrequency, value: notchMinimumFrequency)
        internalAU?.setParameterImmediately(.notchMaximumFrequency, value: notchMaximumFrequency)
        internalAU?.setParameterImmediately(.notchWidth, value: notchWidth)
        internalAU?.setParameterImmediately(.notchFrequency, value: notchFrequency)
        internalAU?.setParameterImmediately(.vibratoMode, value: vibratoMode)
        internalAU?.setParameterImmediately(.depth, value: depth)
        internalAU?.setParameterImmediately(.feedback, value: feedback)
        internalAU?.setParameterImmediately(.inverted, value: inverted)
        internalAU?.setParameterImmediately(.lfoBPM, value: lfoBPM)
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
