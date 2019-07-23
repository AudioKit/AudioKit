//
//  AKMorphingOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    @objc open dynamic var index: Double = 0.0 {
        willSet {
            guard index != newValue else { return }
            if internalAU?.isSetUp == true {
                indexParameter?.value = AUValue(newValue)
                return
            } else {
                internalAU?.index = AUValue(newValue)
            }
        }
    }

    /// Attack duration in seconds
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            guard attackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                attackDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.attackDuration = AUValue(newValue)
            }
        }
    }

    /// Decay duration in seconds
    @objc open dynamic var decayDuration: Double = 0.1 {
        willSet {
            guard decayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                decayDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.decayDuration = AUValue(newValue)
            }
        }
    }

    /// Sustain Level
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            guard sustainLevel != newValue else { return }
            if internalAU?.isSetUp == true {
                sustainLevelParameter?.value = AUValue(newValue)
            } else {
                internalAU?.sustainLevel = AUValue(newValue)
            }
        }
    }

    /// Release duration in seconds
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            guard releaseDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                releaseDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.releaseDuration = AUValue(newValue)
            }
        }
    }

    /// Pitch Bend as number of semitones
    @objc open dynamic var pitchBend: Double = 0 {
        willSet {
            guard pitchBend != newValue else { return }
            if internalAU?.isSetUp == true {
                pitchBendParameter?.value = AUValue(newValue)
            } else {
                internalAU?.pitchBend = AUValue(newValue)
            }
        }
    }

    /// Vibrato Depth in semitones
    @objc open dynamic var vibratoDepth: Double = 0 {
        willSet {
            guard vibratoDepth != newValue else { return }
            if internalAU?.isSetUp == true {
                vibratoDepthParameter?.value = AUValue(newValue)
            } else {
                internalAU?.vibratoDepth = AUValue(newValue)
            }
        }
    }

    /// Vibrato Rate in Hz
    @objc open dynamic var vibratoRate: Double = 0 {
        willSet {
            guard vibratoRate != newValue else { return }
            if internalAU?.isSetUp == true {
                vibratoRateParameter?.value = AUValue(newValue)
            } else {
                internalAU?.vibratoRate = AUValue(newValue)
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    @objc public convenience override init() {
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveformArray:      An array of 4 waveforms
    ///   - index:              Index of the wavetable to use (fractional are okay).
    ///   - attackDuration:     Attack duration in seconds
    ///   - decayDuration:      Decay duration in seconds
    ///   - sustainLevel:       Sustain Level
    ///   - releaseDuration:    Release duration in seconds
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
            self?.avAudioUnit = avAudioUnit
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
    open override func play(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            frequency: Double,
                            channel: MIDIChannel = 0) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: Float(frequency))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
