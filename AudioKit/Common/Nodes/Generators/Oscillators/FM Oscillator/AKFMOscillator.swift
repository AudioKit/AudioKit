//
//  AKFMOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Classic FM Synthesis audio generation.
///
open class AKFMOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFMOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "fosc")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var waveform: AKTable?

    fileprivate var baseFrequencyParameter: AUParameter?
    fileprivate var carrierMultiplierParameter: AUParameter?
    fileprivate var modulatingMultiplierParameter: AUParameter?
    fileprivate var modulationIndexParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    open dynamic var baseFrequency: Double = 440 {
        willSet {
            if baseFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        baseFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.baseFrequency = Float(newValue)
                }
            }
        }
    }

    /// This multiplied by the baseFrequency gives the carrier frequency.
    open dynamic var carrierMultiplier: Double = 1.0 {
        willSet {
            if carrierMultiplier != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        carrierMultiplierParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.carrierMultiplier = Float(newValue)
                }
            }
        }
    }

    /// This multiplied by the baseFrequency gives the modulating frequency.
    open dynamic var modulatingMultiplier: Double = 1 {
        willSet {
            if modulatingMultiplier != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        modulatingMultiplierParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.modulatingMultiplier = Float(newValue)
                }
            }
        }
    }

    /// This multiplied by the modulating frequency gives the modulation amplitude.
    open dynamic var modulationIndex: Double = 1 {
        willSet {
            if modulationIndex != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        modulationIndexParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.modulationIndex = Float(newValue)
                }
            }
        }
    }

    /// Output Amplitude.
    open dynamic var amplitude: Double = 1 {
        willSet {
            if amplitude != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.amplitude = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveform: AKTable(.sine))
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform: Shape of the oscillation
    ///   - baseFrequency: In Hz, this is the common denominator for the carrier and modulating frequencies.
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    ///   - amplitude: Output Amplitude.
    ///
    public init(
        waveform: AKTable,
        baseFrequency: Double = 440,
        carrierMultiplier: Double = 1.0,
        modulatingMultiplier: Double = 1,
        modulationIndex: Double = 1,
        amplitude: Double = 1) {

        self.waveform = waveform
        self.baseFrequency = baseFrequency
        self.carrierMultiplier = carrierMultiplier
        self.modulatingMultiplier = modulatingMultiplier
        self.modulationIndex = modulationIndex
        self.amplitude = amplitude

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self?.internalAU?.setupWaveform(Int32(waveform.count))
            for (i, sample) in waveform.enumerated() {
                self?.internalAU?.setWaveformValue(sample, at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        baseFrequencyParameter = tree["baseFrequency"]
        carrierMultiplierParameter = tree["carrierMultiplier"]
        modulatingMultiplierParameter = tree["modulatingMultiplier"]
        modulationIndexParameter = tree["modulationIndex"]
        amplitudeParameter = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.baseFrequencyParameter?.address {
                    self?.baseFrequency = Double(value)
                } else if address == self?.carrierMultiplierParameter?.address {
                    self?.carrierMultiplier = Double(value)
                } else if address == self?.modulatingMultiplierParameter?.address {
                    self?.modulatingMultiplier = Double(value)
                } else if address == self?.modulationIndexParameter?.address {
                    self?.modulationIndex = Double(value)
                } else if address == self?.amplitudeParameter?.address {
                    self?.amplitude = Double(value)
                }
            }
        })
        internalAU?.baseFrequency = Float(baseFrequency)
        internalAU?.carrierMultiplier = Float(carrierMultiplier)
        internalAU?.modulatingMultiplier = Float(modulatingMultiplier)
        internalAU?.modulationIndex = Float(modulationIndex)
        internalAU?.amplitude = Float(amplitude)
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
