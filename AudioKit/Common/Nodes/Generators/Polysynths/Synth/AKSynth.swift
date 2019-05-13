//
//  AKSynth.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

/// Synth
///
@objc open class AKSynth: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSynthAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "AKsy")

    // MARK: - Properties

    @objc public var internalAU: AKAudioUnitType?

    fileprivate var masterVolumeParameter: AUParameter?
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var filterCutoffParameter: AUParameter?
    fileprivate var filterStrengthParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?

    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Master volume (fraction)
    @objc open dynamic var masterVolume: Double = 1.0 {
        willSet {
            guard masterVolume != newValue else { return }

            if internalAU?.isSetUp == true {
                masterVolumeParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.masterVolume = newValue
        }
    }

    /// Pitch offset (semitones)
    @objc open dynamic var pitchBend: Double = 0.0 {
        willSet {
            guard pitchBend != newValue else { return }

            if internalAU?.isSetUp == true {
                pitchBendParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.pitchBend = newValue
        }
    }

    /// Vibrato amount (semitones)
    @objc open dynamic var vibratoDepth: Double = 1.0 {
        willSet {
            guard vibratoDepth != newValue else { return }

            if internalAU?.isSetUp == true {
                vibratoDepthParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.vibratoDepth = newValue
        }
    }

    /// Filter cutoff (harmonic ratio)
    @objc open dynamic var filterCutoff: Double = 4.0 {
        willSet {
            guard filterCutoff != newValue else { return }

            if internalAU?.isSetUp == true {
                filterCutoffParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.filterCutoff = newValue
        }
    }

    /// Filter EG strength (harmonic ratio)
    @objc open dynamic var filterStrength: Double = 20.0 {
        willSet {
            guard filterStrength != newValue else { return }

            if internalAU?.isSetUp == true {
                filterStrengthParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.filterStrength = newValue
        }
    }

    /// Filter resonance (dB)
    @objc open dynamic var filterResonance: Double = 0.0 {
        willSet {
            guard filterResonance != newValue else { return }

            if internalAU?.isSetUp == true {
                filterResonanceParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.filterResonance = newValue
        }
    }

    /// Amplitude attack duration (seconds)
    @objc open dynamic var attackDuration: Double = 0.0 {
        willSet {
            guard attackDuration != newValue else { return }
            internalAU?.attackDuration = newValue
        }
    }

    /// Amplitude Decay duration (seconds)
    @objc open dynamic var decayDuration: Double = 0.0 {
        willSet {
            guard decayDuration != newValue else { return }
            internalAU?.decayDuration = newValue
        }
    }

    /// Amplitude sustain level (fraction)
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            guard sustainLevel != newValue else { return }
            internalAU?.sustainLevel = newValue
        }
    }

    /// Amplitude Release duration (seconds)
    @objc open dynamic var releaseDuration: Double = 0.0 {
        willSet {
            guard releaseDuration != newValue else { return }
            internalAU?.releaseDuration = newValue
        }
    }

    /// Filter attack duration (seconds)
    @objc open dynamic var filterAttackDuration: Double = 0.0 {
        willSet {
            guard filterAttackDuration != newValue else { return }
            internalAU?.filterAttackDuration = newValue
        }
    }

    /// Filter Decay duration (seconds)
    @objc open dynamic var filterDecayDuration: Double = 0.0 {
        willSet {
            guard filterDecayDuration != newValue else { return }
            internalAU?.filterDecayDuration = newValue
        }
    }

    /// Filter sustain level (fraction)
    @objc open dynamic var filterSustainLevel: Double = 1.0 {
        willSet {
            guard filterSustainLevel != newValue else { return }
            internalAU?.filterSustainLevel = newValue
        }
    }

    /// Filter Release duration (seconds)
    @objc open dynamic var filterReleaseDuration: Double = 0.0 {
        willSet {
            guard filterReleaseDuration != newValue else { return }
            internalAU?.filterReleaseDuration = newValue
        }
    }

    // MARK: - Initialization

    /// Initialize this synth node
    ///
    /// - Parameters:
    ///   - masterVolume: 0.0 - 1.0
    ///   - pitchBend: semitones, signed
    ///   - vibratoDepth: semitones, typically less than 1.0
    ///   - filterCutoff: relative to sample playback pitch, 1.0 = fundamental, 2.0 = 2nd harmonic etc
    ///   - filterStrength: same units as filterCutoff; amount filter EG adds to filterCutoff
    ///   - filterResonance: dB, -20.0 - 20.0
    ///   - attackDuration: seconds, 0.0 - 10.0
    ///   - decayDuration: seconds, 0.0 - 10.0
    ///   - sustainLevel: 0.0 - 1.0
    ///   - releaseDuration: seconds, 0.0 - 10.0
    ///   - filterEnable: true to enable per-voice filters
    ///   - filterAttackDuration: seconds, 0.0 - 10.0
    ///   - filterDecayDuration: seconds, 0.0 - 10.0
    ///   - filterSustainLevel: 0.0 - 1.0
    ///   - filterReleaseDuration: seconds, 0.0 - 10.0
    ///
    @objc public init(
        masterVolume: Double = 1.0,
        pitchBend: Double = 0.0,
        vibratoDepth: Double = 0.0,
        filterCutoff: Double = 4.0,
        filterStrength: Double = 20.0,
        filterResonance: Double = 0.0,
        attackDuration: Double = 0.0,
        decayDuration: Double = 0.0,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.0,
        filterEnable: Bool = false,
        filterAttackDuration: Double = 0.0,
        filterDecayDuration: Double = 0.0,
        filterSustainLevel: Double = 1.0,
        filterReleaseDuration: Double = 0.0) {

        self.masterVolume = masterVolume
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.filterCutoff = filterCutoff
        self.filterStrength = filterStrength
        self.filterResonance = filterResonance
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.filterAttackDuration = filterAttackDuration
        self.filterDecayDuration = filterDecayDuration
        self.filterSustainLevel = filterSustainLevel
        self.filterReleaseDuration = filterReleaseDuration

        AKSynth.register()

        super.init()

        AVAudioUnit._instantiate(with: AKSynth.ComponentDescription) { [weak self] avAudioUnit in
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

        self.masterVolumeParameter = tree["masterVolume"]
        self.pitchBendParameter = tree["pitchBend"]
        self.vibratoDepthParameter = tree["vibratoDepth"]
        self.filterCutoffParameter = tree["filterCutoff"]
        self.filterStrengthParameter = tree["filterStrength"]
        self.filterResonanceParameter = tree["filterResonance"]
        self.attackDurationParameter = tree["attackDuration"]
        self.decayDurationParameter = tree["decayDuration"]
        self.sustainLevelParameter = tree["sustainLevel"]
        self.releaseDurationParameter = tree["releaseDuration"]
        self.filterAttackDurationParameter = tree["filterAttackDuration"]
        self.filterDecayDurationParameter = tree["filterDecayDuration"]
        self.filterSustainLevelParameter = tree["filterSustainLevel"]
        self.filterReleaseDurationParameter = tree["filterReleaseDuration"]

        self.internalAU?.setParameterImmediately(.masterVolume, value: masterVolume)
        self.internalAU?.setParameterImmediately(.pitchBend, value: pitchBend)
        self.internalAU?.setParameterImmediately(.vibratoDepth, value: vibratoDepth)
        self.internalAU?.setParameterImmediately(.filterCutoff, value: filterCutoff)
        self.internalAU?.setParameterImmediately(.filterStrength, value: filterStrength)
        self.internalAU?.setParameterImmediately(.filterResonance, value: filterResonance)
        self.internalAU?.setParameterImmediately(.attackDuration, value: attackDuration)
        self.internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
        self.internalAU?.setParameterImmediately(.sustainLevel, value: sustainLevel)
        self.internalAU?.setParameterImmediately(.releaseDuration, value: releaseDuration)
        self.internalAU?.setParameterImmediately(.filterAttackDuration, value: filterAttackDuration)
        self.internalAU?.setParameterImmediately(.filterDecayDuration, value: filterDecayDuration)
        self.internalAU?.setParameterImmediately(.filterSustainLevel, value: filterSustainLevel)
        self.internalAU?.setParameterImmediately(.filterReleaseDuration, value: filterReleaseDuration)
    }

    @objc open override func play(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  frequency: Double,
                                  channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity, noteFrequency: Float(frequency))
    }

    @objc open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: false)
    }

    @objc open func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: true)
    }

    @objc open func sustainPedal(pedalDown: Bool) {
        internalAU?.sustainPedal(down: pedalDown)
    }
}
