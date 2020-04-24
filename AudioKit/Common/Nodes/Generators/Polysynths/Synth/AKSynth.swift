//
//  AKSynth.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

/// Synth
///
open class AKSynth: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSynthAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "AKsy")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Master volume (fraction)
    open var masterVolume: Double = 1.0 {
        willSet {
            guard masterVolume != newValue else { return }
            internalAU?.masterVolume.value = AUValue(newValue)
        }
    }

    /// Pitch offset (semitones)
    open var pitchBend: Double = 0.0 {
        willSet {
            guard pitchBend != newValue else { return }
            internalAU?.pitchBend.value = AUValue(newValue)
        }
    }

    /// Vibrato amount (semitones)
    open var vibratoDepth: Double = 1.0 {
        willSet {
            guard vibratoDepth != newValue else { return }
            internalAU?.vibratoDepth.value = AUValue(newValue)
        }
    }

    /// Filter cutoff (harmonic ratio)
    open var filterCutoff: Double = 4.0 {
        willSet {
            guard filterCutoff != newValue else { return }
            internalAU?.filterCutoff.value = AUValue(newValue)
        }
    }

    /// Filter EG strength (harmonic ratio)
    open var filterStrength: Double = 20.0 {
        willSet {
            guard filterStrength != newValue else { return }
            internalAU?.filterStrength.value = AUValue(newValue)
        }
    }

    /// Filter resonance (dB)
    open var filterResonance: Double = 0.0 {
        willSet {
            guard filterResonance != newValue else { return }
            internalAU?.filterResonance.value = AUValue(newValue)
        }
    }

    /// Amplitude attack duration (seconds)
    open var attackDuration: Double = 0.0 {
        willSet {
            guard attackDuration != newValue else { return }
            internalAU?.attackDuration.value = AUValue(newValue)
        }
    }

    /// Amplitude Decay duration (seconds)
    open var decayDuration: Double = 0.0 {
        willSet {
            guard decayDuration != newValue else { return }
            internalAU?.decayDuration.value = AUValue(newValue)
        }
    }

    /// Amplitude sustain level (fraction)
    open var sustainLevel: Double = 1.0 {
        willSet {
            guard sustainLevel != newValue else { return }
            internalAU?.sustainLevel.value = AUValue(newValue)
        }
    }

    /// Amplitude Release duration (seconds)
    open var releaseDuration: Double = 0.0 {
        willSet {
            guard releaseDuration != newValue else { return }
            internalAU?.releaseDuration.value = AUValue(newValue)
        }
    }

    /// Filter attack duration (seconds)
    open var filterAttackDuration: Double = 0.0 {
        willSet {
            guard filterAttackDuration != newValue else { return }
            internalAU?.filterAttackDuration.value = AUValue(newValue)
        }
    }

    /// Filter Decay duration (seconds)
    open var filterDecayDuration: Double = 0.0 {
        willSet {
            guard filterDecayDuration != newValue else { return }
            internalAU?.filterDecayDuration.value = AUValue(newValue)
        }
    }

    /// Filter sustain level (fraction)
    open var filterSustainLevel: Double = 1.0 {
        willSet {
            guard filterSustainLevel != newValue else { return }
            internalAU?.filterSustainLevel.value = AUValue(newValue)
        }
    }

    /// Filter Release duration (seconds)
    open var filterReleaseDuration: Double = 0.0 {
        willSet {
            guard filterReleaseDuration != newValue else { return }
            internalAU?.filterReleaseDuration.value = AUValue(newValue)
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
    public init(
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
        filterReleaseDuration: Double = 0.0
    ) {
        super.init()

        AKSynth.register()
        AVAudioUnit._instantiate(with: AKSynth.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

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
        }
    }

    open override func play(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  frequency: Double,
                                  channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity, noteFrequency: Float(frequency))
    }

    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: false)
    }

    open func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: true)
    }

    open func sustainPedal(pedalDown: Bool) {
        internalAU?.sustainPedal(down: pedalDown)
    }
}
