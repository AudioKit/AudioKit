//
//  AKMorphingOscillatorFilterSynth.swift
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
open class AKMorphingOscillatorFilterSynth: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKMorphingOscillatorFilterSynthAudioUnit
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
    fileprivate var filterCutoffFrequencyParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?
    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?
    fileprivate var filterEnvelopeStrengthParameter: AUParameter?
    fileprivate var filterLFODepthParameter: AUParameter?
    fileprivate var filterLFORateParameter: AUParameter?

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
    /// Filter Cutoff Frequency in Hz
    @objc open dynamic var filterCutoffFrequency: Double = 22_050.0 {
        willSet {
            guard filterCutoffFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                filterCutoffFrequencyParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterCutoffFrequency = AUValue(newValue)
            }
        }
    }

    /// Filter Resonance
    @objc open dynamic var filterResonance: Double = 22_050.0 {
        willSet {
            guard filterResonance != newValue else { return }
            if internalAU?.isSetUp == true {
                filterResonanceParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterResonance = AUValue(newValue)
            }
        }
    }

    /// Filter Attack Duration in seconds
    @objc open dynamic var filterAttackDuration: Double = 0.1 {
        willSet {
            guard filterAttackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                filterAttackDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterAttackDuration = AUValue(newValue)
            }
        }
    }

    /// Filter Decay Duration in seconds
    @objc open dynamic var filterDecayDuration: Double = 0.1 {
        willSet {
            guard filterDecayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                filterDecayDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterDecayDuration = AUValue(newValue)
            }
        }
    }
    /// Filter Sustain Level
    @objc open dynamic var filterSustainLevel: Double = 1.0 {
        willSet {
            guard filterSustainLevel != newValue else { return }
            if internalAU?.isSetUp == true {
                filterSustainLevelParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterSustainLevel = AUValue(newValue)
            }
        }
    }
    /// Filter Release Duration in seconds
    @objc open dynamic var filterReleaseDuration: Double = 0.1 {
        willSet {
            guard filterReleaseDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                filterReleaseDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterReleaseDuration = AUValue(newValue)
            }
        }
    }
    ///Filter Envelope Strength
    @objc open dynamic var filterEnvelopeStrength: Double = 0.1 {
        willSet {
            guard filterEnvelopeStrength != newValue else { return }
            if internalAU?.isSetUp == true {
                filterEnvelopeStrengthParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterEnvelopeStrength = AUValue(newValue)
            }
        }
    }
    ///Filter LFO Depth
    @objc open dynamic var filterLFODepth: Double = 0.1 {
        willSet {
            guard filterLFODepth != newValue else { return }
            if internalAU?.isSetUp == true {
                filterLFODepthParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterLFODepth = AUValue(newValue)
            }
        }
    }
    ///Filter LFO Rate
    @objc open dynamic var filterLFORate: Double = 0.1 {
        willSet {
            guard filterLFORate != newValue else { return }
            if internalAU?.isSetUp == true {
                filterLFORateParameter?.value = AUValue(newValue)
            } else {
                internalAU?.filterLFORate = AUValue(newValue)
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
    ///   - filterCutoffFrequency: Frequency of filter cutoff in Hz
    ///   - filterResonance: Filter resonance
    ///   - filterAttackDuration: Filter attack duration in seconds
    ///   - filterDecayDuration: Filter decay duration in seconds
    ///   - filterSustainLevel: Filter sustain level
    ///   - filterReleaseDuration: Filter release duration in seconds
    ///   - filterEnvelopeStrength: Strength of the filter envelope on filter
    ///   - filterLFODepth: Depth of LFO on filter
    ///   - filterLFORate: Speed of filter LFO
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
        vibratoRate: Double = 0,
        filterCutoffFrequency: Double = 22_050.0,
        filterResonance: Double = 0.0,
        filterAttackDuration: Double = 0.1,
        filterDecayDuration: Double = 0.1,
        filterSustainLevel: Double = 1.0,
        filterReleaseDuration: Double = 1.0,
        filterEnvelopeStrength: Double = 0.0,
        filterLFODepth: Double = 0.0,
        filterLFORate: Double = 0.0) {

        self.waveformArray = waveformArray
        self.index = index

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.vibratoRate = vibratoRate
        self.filterCutoffFrequency = filterCutoffFrequency
        self.filterResonance = filterResonance
        self.filterAttackDuration = filterAttackDuration
        self.filterDecayDuration = filterDecayDuration
        self.filterSustainLevel = filterSustainLevel
        self.filterReleaseDuration = filterReleaseDuration
        self.filterEnvelopeStrength = filterEnvelopeStrength
        self.filterLFODepth = filterLFODepth
        self.filterLFORate = filterLFORate

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
        filterCutoffFrequencyParameter = tree["filterCutoffFrequency"]
        filterResonanceParameter = tree["filterResonance"]
        filterAttackDurationParameter = tree["filterAttackDuration"]
        filterDecayDurationParameter = tree["filterDecayDuration"]
        filterSustainLevelParameter = tree["filterSustainLevel"]
        filterReleaseDurationParameter = tree["filterReleaseDuration"]
        filterEnvelopeStrengthParameter = tree["filterEnvelopeStrength"]
        filterLFODepthParameter = tree["filterLFODepth"]
        filterLFORateParameter = tree["filterLFORate"]

        internalAU?.index = Float(index)

        internalAU?.attackDuration = Float(attackDuration)
        internalAU?.decayDuration = Float(decayDuration)
        internalAU?.sustainLevel = Float(sustainLevel)
        internalAU?.releaseDuration = Float(releaseDuration)
        internalAU?.pitchBend = Float(pitchBend)
        internalAU?.vibratoDepth = Float(vibratoDepth)
        internalAU?.vibratoRate = Float(vibratoRate)
        internalAU?.filterCutoffFrequency = Float(filterCutoffFrequency)
        internalAU?.filterResonance = Float(filterResonance)
        internalAU?.filterAttackDuration = Float(filterAttackDuration)
        internalAU?.filterDecayDuration = Float(filterDecayDuration)
        internalAU?.filterSustainLevel = Float(filterSustainLevel)
        internalAU?.filterReleaseDuration = Float(filterReleaseDuration)
        internalAU?.filterEnvelopeStrength = Float(filterEnvelopeStrength)
        internalAU?.filterLFODepth = Float(filterLFODepth)
        internalAU?.filterLFORate = Float(filterLFORate)
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
