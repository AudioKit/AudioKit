//
//  AKFMOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Classic FM Synthesis audio generation.
///
open class AKFMOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFMOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "fosc")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var waveform: AKTable?

    fileprivate var baseFrequencyParameter: AUParameter?
    fileprivate var carrierMultiplierParameter: AUParameter?
    fileprivate var modulatingMultiplierParameter: AUParameter?
    fileprivate var modulationIndexParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Lower and upper bounds for Base Frequency
    public static let baseFrequencyRange = 0.0 ... 20_000.0

    /// Lower and upper bounds for Carrier Multiplier
    public static let carrierMultiplierRange = 0.0 ... 1_000.0

    /// Lower and upper bounds for Modulating Multiplier
    public static let modulatingMultiplierRange = 0.0 ... 1_000.0

    /// Lower and upper bounds for Modulation Index
    public static let modulationIndexRange = 0.0 ... 1_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 10.0

    /// Initial value for Base Frequency
    public static let defaultBaseFrequency = 440.0

    /// Initial value for Carrier Multiplier
    public static let defaultCarrierMultiplier = 1.0

    /// Initial value for Modulating Multiplier
    public static let defaultModulatingMultiplier = 1.0

    /// Initial value for Modulation Index
    public static let defaultModulationIndex = 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 1.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    @objc open dynamic var baseFrequency: Double = defaultBaseFrequency {
        willSet {
            guard baseFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                baseFrequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.baseFrequency, value: newValue)
        }
    }

    /// This multiplied by the baseFrequency gives the carrier frequency.
    @objc open dynamic var carrierMultiplier: Double = defaultCarrierMultiplier {
        willSet {
            guard carrierMultiplier != newValue else { return }
            if internalAU?.isSetUp == true {
                carrierMultiplierParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.carrierMultiplier, value: newValue)
        }
    }

    /// This multiplied by the baseFrequency gives the modulating frequency.
    @objc open dynamic var modulatingMultiplier: Double = defaultModulatingMultiplier {
        willSet {
            guard modulatingMultiplier != newValue else { return }
            if internalAU?.isSetUp == true {
                modulatingMultiplierParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.modulatingMultiplier, value: newValue)
        }
    }

    /// This multiplied by the modulating frequency gives the modulation amplitude.
    @objc open dynamic var modulationIndex: Double = defaultModulationIndex {
        willSet {
            guard modulationIndex != newValue else { return }
            if internalAU?.isSetUp == true {
                modulationIndexParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.modulationIndex, value: newValue)
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
    ///   - waveform: The waveform of oscillation
    ///   - baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    ///   - amplitude: Output Amplitude.
    ///
    @objc public init(
        waveform: AKTable,
        baseFrequency: Double = defaultBaseFrequency,
        carrierMultiplier: Double = defaultCarrierMultiplier,
        modulatingMultiplier: Double = defaultModulatingMultiplier,
        modulationIndex: Double = defaultModulationIndex,
        amplitude: Double = defaultAmplitude) {

        self.waveform = waveform
        self.baseFrequency = baseFrequency
        self.carrierMultiplier = carrierMultiplier
        self.modulatingMultiplier = modulatingMultiplier
        self.modulationIndex = modulationIndex
        self.amplitude = amplitude

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

        baseFrequencyParameter = tree["baseFrequency"]
        carrierMultiplierParameter = tree["carrierMultiplier"]
        modulatingMultiplierParameter = tree["modulatingMultiplier"]
        modulationIndexParameter = tree["modulationIndex"]
        amplitudeParameter = tree["amplitude"]
        internalAU?.setParameterImmediately(.baseFrequency, value: baseFrequency)
        internalAU?.setParameterImmediately(.carrierMultiplier, value: carrierMultiplier)
        internalAU?.setParameterImmediately(.modulatingMultiplier, value: modulatingMultiplier)
        internalAU?.setParameterImmediately(.modulationIndex, value: modulationIndex)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
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
