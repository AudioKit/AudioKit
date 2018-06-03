//
//  AKMorphingOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
open class AKMorphingOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKMorphingOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "morf")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var waveformArray = [AKTable]()
    fileprivate var phase: Double

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?
    fileprivate var indexParameter: AUParameter?
    fileprivate var detuningOffsetParameter: AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange = 0.0 ... 22_050.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 1.0

    /// Lower and upper bounds for Index
    public static let indexRange = 0.0 ... 3.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 0.5

    /// Initial value for Index
    public static let defaultIndex = 0.0

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset = 0.0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier = 1.0

    /// Initial value for Phase
    public static let defaultPhase = 0.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Frequency (in Hz)
    @objc open dynamic var frequency: Double = defaultFrequency {
        willSet {
            if frequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    frequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.frequency, value: newValue)
        }
    }

    /// Amplitude (typically a value between 0 and 1).
    @objc open dynamic var amplitude: Double = defaultAmplitude {
        willSet {
            if amplitude == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.amplitude, value: newValue)
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    @objc open dynamic var index: Double = defaultIndex {
        willSet {
            if index == newValue {
                return
            }
            let transformedValue = Float(newValue) / Float(waveformArray.count - 1)
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    indexParameter?.setValue(Float(transformedValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.index, value: Double(transformedValue))
        }
    }

    /// Frequency offset in Hz.
    @objc open dynamic var detuningOffset: Double = defaultDetuningOffset {
        willSet {
            if detuningOffset == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    detuningOffsetParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.detuningOffset, value: newValue)
        }
    }

    /// Frequency detuning multiplier
    @objc open dynamic var detuningMultiplier: Double = defaultDetuningMultiplier {
        willSet {
            if detuningMultiplier == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    detuningMultiplierParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
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
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this Morpher node
    ///
    /// - Parameters:
    ///   - waveformArray: An array of exactly four waveforms
    ///   - frequency: Frequency (in Hz)
    ///   - amplitude: Amplitude (typically a value between 0 and 1).
    ///   - index: Index of the wavetable to use (fractional are okay).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///   - phase: Initial phase of waveform, expects a value 0-1
    ///
    @objc public init(
        waveformArray: [AKTable],
        frequency: Double = defaultFrequency,
        amplitude: Double = defaultAmplitude,
        index: Double = defaultIndex,
        detuningOffset: Double = defaultDetuningOffset,
        detuningMultiplier: Double = defaultDetuningMultiplier,
        phase: Double = defaultPhase) {

        self.waveformArray = waveformArray
        self.frequency = frequency
        self.amplitude = amplitude
        self.phase = phase
        self.index = index
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            for (i, waveform) in waveformArray.enumerated() {
                strongSelf.internalAU?.setupIndividualWaveform(UInt32(i), size: Int32(waveform.count))
                for (j, sample) in waveform.enumerated() {
                    strongSelf.internalAU?.setIndividualWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        amplitudeParameter = tree["amplitude"]
        indexParameter = tree["index"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

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
        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
        internalAU?.setParameterImmediately(.index, value: Float(index) / Float(waveformArray.count - 1))
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
