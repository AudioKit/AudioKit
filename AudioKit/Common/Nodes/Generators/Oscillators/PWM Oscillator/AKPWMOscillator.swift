//
//  AKPWMOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
open class AKPWMOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPWMOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pwmo")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?
    fileprivate var pulseWidthParameter: AUParameter?
    fileprivate var detuningOffsetParameter: AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange = 0.0 ... 20_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 10.0

    /// Lower and upper bounds for Pulse Width
    public static let pulseWidthRange = 0.0 ... 1.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 1.0

    /// Initial value for Pulse Width
    public static let defaultPulseWidth = 0.5

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset = 0.0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier = 1.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Frequency in cycles per second
    @objc open dynamic var frequency: Double = defaultFrequency {
        willSet {
            guard frequency != newValue else { return }
            if internalAU?.isSetUp == true {
                frequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.frequency, value: newValue)
        }
    }

    /// Output Amplitude.
    @objc open dynamic var amplitude: Double = defaultAmplitude {
        willSet {
            guard amplitude != newValue else { return }
            if internalAU?.isSetUp == true {
                amplitudeParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.amplitude, value: newValue)
        }
    }

    /// Duty Cycle Width 0 - 1
    @objc open dynamic var pulseWidth: Double = defaultPulseWidth {
        willSet {
            guard pulseWidth != newValue else { return }
            if internalAU?.isSetUp == true {
                pulseWidthParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.pulseWidth, value: newValue)
        }
    }

    /// Frequency offset in Hz.
    @objc open dynamic var detuningOffset: Double = defaultDetuningOffset {
        willSet {
            guard detuningOffset != newValue else { return }
            if internalAU?.isSetUp == true {
                detuningOffsetParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.detuningOffset, value: newValue)
        }
    }

    /// Frequency detuning multiplier
    @objc open dynamic var detuningMultiplier: Double = defaultDetuningMultiplier {
        willSet {
            guard detuningMultiplier != newValue else { return }
            if internalAU?.isSetUp == true {
                detuningMultiplierParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.detuningMultiplier, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(frequency: 440)
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz.
    ///   - amplitude: Output amplitude
    ///   - pulseWidth: Duty cycle width (range 0-1).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    @objc public init(
        frequency: Double,
        amplitude: Double = defaultAmplitude,
        pulseWidth: Double = defaultPulseWidth,
        detuningOffset: Double = defaultDetuningOffset,
        detuningMultiplier: Double = defaultDetuningMultiplier) {

        self.frequency = frequency
        self.amplitude = amplitude
        self.pulseWidth = pulseWidth
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

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
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        amplitudeParameter = tree["amplitude"]
        pulseWidthParameter = tree["pulseWidth"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]
        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
        internalAU?.setParameterImmediately(.pulseWidth, value: pulseWidth)
        internalAU?.setParameterImmediately(.detuningOffset, value: detuningOffset)
        internalAU?.setParameterImmediately(.detuningMultiplier, value: detuningMultiplier)
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
