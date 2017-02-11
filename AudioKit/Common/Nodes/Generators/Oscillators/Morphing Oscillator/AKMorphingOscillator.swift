//
//  AKMorphingOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
open class AKMorphingOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKMorphingOscillatorAudioUnit
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

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// In cycles per second, or Hz.
    open var frequency: Double = 440 {
        willSet {
            if frequency != newValue {
                if internalAU!.isSetUp() {
                    frequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }

    /// Output Amplitude.
    open var amplitude: Double = 1 {
        willSet {
            if amplitude != newValue {
                if internalAU!.isSetUp() {
                    amplitudeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.amplitude = Float(newValue)
                }
            }
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    open var index: Double = 0.0 {
        willSet {
            let transformedValue = Float(newValue) / Float(waveformArray.count - 1)
//            if internalAU!.isSetUp() {
//                indexParameter?.setValue(Float(transformedValue), originator: token!)
//            } else {
                internalAU?.index = Float(transformedValue)
//            }
        }
    }

    /// Frequency offset in Hz.
    open var detuningOffset: Double = 0 {
        willSet {
            if detuningOffset != newValue {
                if internalAU!.isSetUp() {
                    detuningOffsetParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.detuningOffset = Float(newValue)
                }
            }
        }
    }

    /// Frequency detuning multiplier
    open var detuningMultiplier: Double = 1 {
        willSet {
            if detuningMultiplier != newValue {
                if internalAU!.isSetUp() {
                    detuningMultiplierParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.detuningMultiplier = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this Morpher node
    ///
    /// - Parameters:
    ///   - waveformArray:      An array of exactly four waveforms
    ///   - frequency:          Frequency (in Hz)
    ///   - amplitude:          Amplitude (typically a value between 0 and 1).
    ///   - index:              Index of the wavetable to use (fractional are okay).
    ///   - detuningOffset:     Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///   - phase:              Initial phase of waveform, expects a value 0-1
    ///
    public init(
        waveformArray: [AKTable],
        frequency: Double = 440,
        amplitude: Double = 0.5,
        index: Double = 0.0,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1,
        phase: Double = 0) {

        self.waveformArray = waveformArray
        self.frequency = frequency
        self.amplitude = amplitude
        self.phase = phase
        self.index = index
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in
            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit .auAudioUnit as? AKAudioUnitType

            for (i, waveform) in waveformArray.enumerated() {
                self?.internalAU?.setupWaveform(UInt32(i), size: Int32(waveform.count))
                for (j, sample) in waveform.enumerated() {
                    self?.internalAU?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree["frequency"]
        amplitudeParameter = tree["amplitude"]
        indexParameter = tree["index"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

        token = tree.token (byAddingParameterObserver: { [weak self]
            address, value in

            DispatchQueue.main.async {
                if address == self?.frequencyParameter!.address {
                    self?.frequency = Double(value)
                } else if address == self?.amplitudeParameter!.address {
                    self?.amplitude = Double(value)
                } else if address == self?.indexParameter!.address {
                    self?.index = Double(value)
                } else if address == self?.detuningOffsetParameter!.address {
                    self?.detuningOffset = Double(value)
                } else if address == self?.detuningMultiplierParameter!.address {
                    self?.detuningMultiplier = Double(value)
                }
            }
        })
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.index = Float(index) / Float(waveformArray.count - 1)
        internalAU?.detuningOffset = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
