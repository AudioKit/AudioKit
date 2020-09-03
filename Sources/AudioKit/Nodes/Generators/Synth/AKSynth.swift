// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Synth
///
public class AKSynth: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSynthAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "AKsy")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Master volume (fraction)
    open var masterVolume: AUValue = 1.0 {
        willSet {
            guard masterVolume != newValue else { return }
            internalAU?.masterVolume.value = newValue
        }
    }

    /// Pitch offset (semitones)
    open var pitchBend: AUValue = 0.0 {
        willSet {
            guard pitchBend != newValue else { return }
            internalAU?.pitchBend.value = newValue
        }
    }

    /// Vibrato amount (semitones)
    open var vibratoDepth: AUValue = 1.0 {
        willSet {
            guard vibratoDepth != newValue else { return }
            internalAU?.vibratoDepth.value = newValue
        }
    }

    /// Filter cutoff (harmonic ratio)
    open var filterCutoff: AUValue = 4.0 {
        willSet {
            guard filterCutoff != newValue else { return }
            internalAU?.filterCutoff.value = newValue
        }
    }

    /// Filter EG strength (harmonic ratio)
    open var filterStrength: AUValue = 20.0 {
        willSet {
            guard filterStrength != newValue else { return }
            internalAU?.filterStrength.value = newValue
        }
    }

    /// Filter resonance (dB)
    open var filterResonance: AUValue = 0.0 {
        willSet {
            guard filterResonance != newValue else { return }
            internalAU?.filterResonance.value = newValue
        }
    }

    /// Amplitude attack duration (seconds)
    open var attackDuration: AUValue = 0.0 {
        willSet {
            guard attackDuration != newValue else { return }
            internalAU?.attackDuration.value = newValue
        }
    }

    /// Amplitude Decay duration (seconds)
    open var decayDuration: AUValue = 0.0 {
        willSet {
            guard decayDuration != newValue else { return }
            internalAU?.decayDuration.value = newValue
        }
    }

    /// Amplitude sustain level (fraction)
    open var sustainLevel: AUValue = 1.0 {
        willSet {
            guard sustainLevel != newValue else { return }
            internalAU?.sustainLevel.value = newValue
        }
    }

    /// Amplitude Release duration (seconds)
    open var releaseDuration: AUValue = 0.0 {
        willSet {
            guard releaseDuration != newValue else { return }
            internalAU?.releaseDuration.value = newValue
        }
    }

    /// Filter attack duration (seconds)
    open var filterAttackDuration: AUValue = 0.0 {
        willSet {
            guard filterAttackDuration != newValue else { return }
            internalAU?.filterAttackDuration.value = newValue
        }
    }

    /// Filter Decay duration (seconds)
    open var filterDecayDuration: AUValue = 0.0 {
        willSet {
            guard filterDecayDuration != newValue else { return }
            internalAU?.filterDecayDuration.value = newValue
        }
    }

    /// Filter sustain level (fraction)
    open var filterSustainLevel: AUValue = 1.0 {
        willSet {
            guard filterSustainLevel != newValue else { return }
            internalAU?.filterSustainLevel.value = newValue
        }
    }

    /// Filter Release duration (seconds)
    open var filterReleaseDuration: AUValue = 0.0 {
        willSet {
            guard filterReleaseDuration != newValue else { return }
            internalAU?.filterReleaseDuration.value = newValue
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
        masterVolume: AUValue = 1.0,
        pitchBend: AUValue = 0.0,
        vibratoDepth: AUValue = 0.0,
        filterCutoff: AUValue = 4.0,
        filterStrength: AUValue = 20.0,
        filterResonance: AUValue = 0.0,
        attackDuration: AUValue = 0.0,
        decayDuration: AUValue = 0.0,
        sustainLevel: AUValue = 1.0,
        releaseDuration: AUValue = 0.0,
        filterEnable: Bool = false,
        filterAttackDuration: AUValue = 0.0,
        filterDecayDuration: AUValue = 0.0,
        filterSustainLevel: AUValue = 1.0,
        filterReleaseDuration: AUValue = 0.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
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

    public override func play(noteNumber: MIDINoteNumber,
                              velocity: MIDIVelocity,
                              frequency: AUValue,
                              channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity, noteFrequency: frequency)
    }

    public override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: false)
    }

    public func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: true)
    }

    public func sustainPedal(pedalDown: Bool) {
        internalAU?.sustainPedal(down: pedalDown)
    }

    // TODO This node is untested
}
