//
//  AKMorphingOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
open class AKMorphingOscillatorBank: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKMorphingOscillatorBankAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "morb")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    /// An array of tables to morph between
    open var waveformArray = [AKTable]() {
        willSet {
            self.waveformArray = newValue
            for (i, waveform) in self.waveformArray.enumerated() {
                for (j, sample) in waveform.enumerated() {
                    self.internalAU?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }
    }

    fileprivate var indexParameter: AUParameter?

    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var vibratoRateParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    @objc open dynamic var index: Double = 0.0 {
        willSet {
            if attackDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        indexParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.index = Float(newValue)
                }
            }
        }
    }

    /// Attack time
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.attackDuration = Float(newValue)
                }
            }
        }
    }

    /// Decay time
    @objc open dynamic var decayDuration: Double = 0.1 {
        willSet {
            if decayDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        decayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.decayDuration = Float(newValue)
                }
            }
        }
    }
    /// Sustain Level
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        sustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.sustainLevel = Float(newValue)
                }
            }
        }
    }
    /// Release time
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.releaseDuration = Float(newValue)
                }
            }
        }
    }

    /// Pitch Bend as number of semitones
    @objc open dynamic var pitchBend: Double = 0 {
        willSet {
            if pitchBend != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        pitchBendParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.pitchBend = Float(newValue)
                }
            }
        }
    }

    /// Vibrato Depth in semitones
    @objc open dynamic var vibratoDepth: Double = 0 {
        willSet {
            if vibratoDepth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        vibratoDepthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.vibratoDepth = Float(newValue)
                }
            }
        }
    }

    /// Vibrato Rate in Hz
    @objc open dynamic var vibratoRate: Double = 0 {
        willSet {
            if vibratoRate != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        vibratoRateParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.vibratoRate = Float(newValue)
                }
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveformArray:      An array of 4 waveforms
    ///   - index:              Index of the wavetable to use (fractional are okay).
    ///   - attackDuration:     Attack time
    ///   - decayDuration:      Decay time
    ///   - sustainLevel:       Sustain Level
    ///   - releaseDuration:    Release time
    ///   - pitchBend:          Change of pitch in semitones
    ///   - vibratoDepth:       Vibrato size in semitones
    ///   - vibratoRate:        Frequency of vibrato in Hz
    ///
    @objc public init(
        waveformArray: [AKTable],
        index: Double = 0,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1,
        pitchBend: Double = 0,
        vibratoDepth: Double = 0,
        vibratoRate: Double = 0) {

        self.waveformArray = waveformArray
        self.index = index

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.vibratoRate = vibratoRate

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            self?.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            for (i, waveform) in waveformArray.enumerated() {
                self?.internalAU?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
                for (j, sample) in waveform.enumerated() {
                    self?.internalAU?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        indexParameter = tree["index"]

        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]
        pitchBendParameter = tree["pitchBend"]
        vibratoDepthParameter = tree["vibratoDepth"]
        vibratoRateParameter = tree["vibratoRate"]

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
        internalAU?.index = Float(index)

        internalAU?.attackDuration = Float(attackDuration)
        internalAU?.decayDuration = Float(decayDuration)
        internalAU?.sustainLevel = Float(sustainLevel)
        internalAU?.releaseDuration = Float(releaseDuration)
        internalAU?.pitchBend = Float(pitchBend)
        internalAU?.vibratoDepth = Float(vibratoDepth)
        internalAU?.vibratoRate = Float(vibratoRate)
    }

    /// stops all notes
    open func reset() {
        internalAU?.reset()
    }

    // MARK: - AKPolyphonic

    // Function to start, play, or activate the node at frequency
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: Float(frequency))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
