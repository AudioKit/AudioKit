//
//  AKPhaseDistortionOscillator.swift
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
open class AKPhaseDistortionOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPhaseDistortionOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "phdo")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var waveform: AKTable?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?
    fileprivate var phaseDistortionParameter: AUParameter?
    fileprivate var detuningOffsetParameter: AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange = 0.0 ... 20_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 10.0

    /// Lower and upper bounds for Phase Distortion
    public static let phaseDistortionRange = -1.0 ... 1.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 1.0

    /// Initial value for Phase Distortion
    public static let defaultPhaseDistortion = 0.0

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

    /// Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    @objc open dynamic var phaseDistortion: Double = defaultPhaseDistortion {
        willSet {
            guard phaseDistortion != newValue else { return }
            if internalAU?.isSetUp == true {
                phaseDistortionParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.phaseDistortion, value: newValue)
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
        self.init(waveform: AKTable(.sine))
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform:  The waveform of oscillation
    ///   - frequency: In cycles per second, or Hz.
    ///   - amplitude: Output amplitude
    ///   - phaseDistortion: Duty cycle width (range -1 - 1).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    @objc public init(
        waveform: AKTable,
        frequency: Double = defaultFrequency,
        amplitude: Double = defaultAmplitude,
        phaseDistortion: Double = defaultPhaseDistortion,
        detuningOffset: Double = defaultDetuningOffset,
        detuningMultiplier: Double = defaultDetuningMultiplier
    ) {

        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.phaseDistortion = phaseDistortion
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
            strongSelf.internalAU?.setupWaveform(Int32(waveform.count))
            for (i, sample) in waveform.enumerated() {
                strongSelf.internalAU?.setWaveformValue(sample, at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        amplitudeParameter = tree["amplitude"]
        phaseDistortionParameter = tree["phaseDistortion"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
        internalAU?.setParameterImmediately(.phaseDistortion, value: phaseDistortion)
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
