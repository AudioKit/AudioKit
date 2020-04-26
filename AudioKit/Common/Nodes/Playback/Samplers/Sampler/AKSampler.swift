// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Sampler
///
open class AKSampler: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSamplerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "AKss")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?

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

    /// Glide rate (seconds per octave)
    open var glideRate: Double = 0.0 {
        willSet {
            guard glideRate != newValue else { return }
            internalAU?.glideRate.value = AUValue(newValue)
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

    /// Pitch attack duration (seconds)
    open var pitchAttackDuration: Double = 0.0 {
        willSet {
            guard pitchAttackDuration != newValue else { return }
            internalAU?.pitchAttackDuration.value = AUValue(newValue)
        }
    }

    /// Pitch Decay duration (seconds)
    open var pitchDecayDuration: Double = 0.0 {
        willSet {
            guard pitchDecayDuration != newValue else { return }
            internalAU?.pitchDecayDuration.value = AUValue(newValue)
        }
    }

    /// Pitch sustain level (fraction)
    open var pitchSustainLevel: Double = 1.0 {
        willSet {
            guard pitchSustainLevel != newValue else { return }
            internalAU?.pitchSustainLevel.value = AUValue(newValue)
        }
    }

    /// Pitch Release duration (seconds)
    open var pitchReleaseDuration: Double = 0.0 {
        willSet {
            guard pitchReleaseDuration != newValue else { return }
            internalAU?.pitchReleaseDuration.value = AUValue(newValue)
        }
    }

    /// Pitch EG Amount duration (semitones)
    open var pitchADSRSemitones: Double = 0.0 {
        willSet {
            guard pitchADSRSemitones != newValue else { return }
            internalAU?.pitchADSRSemitones.value = AUValue(newValue)
        }
    }

    /// Filter Enable (boolean, 0.0 for false or 1.0 for true)
    open var filterEnable: Bool = false {
        willSet {
            guard filterEnable != newValue else { return }
            internalAU?.filterEnable.value = newValue ? 1.0 : 0.0
        }
    }

    /// Loop Thru Release (boolean, 0.0 for false or 1.0 for true)
    open var loopThruRelease: Bool = false {
        willSet {
            guard loopThruRelease != newValue else { return }
            internalAU?.loopThruRelease.value = newValue ? 1.0 : 0.0
        }
    }

    /// isMonophonic (boolean, 0.0 for false or 1.0 for true)
    open var isMonophonic: Bool = false {
        willSet {
            guard isMonophonic != newValue else { return }
            internalAU?.isMonophonic.value = newValue ? 1.0 : 0.0
        }
    }

    /// isLegato (boolean, 0.0 for false or 1.0 for true)
    open var isLegato: Bool = false {
        willSet {
            guard isLegato != newValue else { return }
            internalAU?.isLegato.value = newValue ? 1.0 : 0.0
        }
    }

    /// keyTrackingFraction (-2.0 to +2.0, normal range 0.0 to 1.0)
    open var keyTrackingFraction: Double = 1.0 {
        willSet {
            guard keyTrackingFraction != newValue else { return }
            internalAU?.keyTrackingFraction.value = AUValue(newValue)
        }
    }

    /// filterEnvelopeVelocityScaling (fraction 0.0 to 1.0)
    open var filterEnvelopeVelocityScaling: Double = 0.0 {
        willSet {
            guard filterEnvelopeVelocityScaling != newValue else { return }
            internalAU?.filterEnvelopeVelocityScaling.value = AUValue(newValue)
        }
    }

    // MARK: - Initialization

    /// Initialize this sampler node
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
    ///   - pitchAttackDuration: seconds, 0.0 - 10.0
    ///   - pitchDecayDuration: seconds, 0.0 - 10.0
    ///   - pitchSustainLevel: 0.0 - 1.0
    ///   - pitchReleaseDuration: seconds, 0.0 - 10.0
    ///   - pitchADSRSemitones: semitones, -100.0 - 100.0   
    ///   - glideRate: seconds/octave, 0.0 - 10.0
    ///   - loopThruRelease: if true, sample will continue looping after key release
    ///   - isMonophonic: true for mono, false for polyphonic
    ///   - isLegato: (mono mode onl) if true, legato notes will not retrigger
    ///   - keyTracking: -2.0 - 2.0, 1.0 means perfect key tracking, 0.0 means none
    ///   - filterEnvelopeVelocityScaling: fraction, 0.0 - 1.0
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
        filterReleaseDuration: Double = 0.0,
        pitchAttackDuration: Double = 0.0,
        pitchDecayDuration: Double = 0.0,
        pitchSustainLevel: Double = 0.0,
        pitchReleaseDuration: Double = 0.0,
        pitchADSRSemitones: Double = 0.0,
        glideRate: Double = 0.0,
        loopThruRelease: Bool = true,
        isMonophonic: Bool = false,
        isLegato: Bool = false,
        keyTracking: Double = 1.0,
        filterEnvelopeVelocityScaling: Double = 0.0
    ) {
        super.init()

        AKSampler.register()
        AVAudioUnit._instantiate(with: AKSampler.ComponentDescription) { avAudioUnit in
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
            self.filterEnable = filterEnable
            self.filterAttackDuration = filterAttackDuration
            self.filterDecayDuration = filterDecayDuration
            self.filterSustainLevel = filterSustainLevel
            self.filterReleaseDuration = filterReleaseDuration
            self.pitchAttackDuration = pitchAttackDuration
            self.pitchDecayDuration = pitchDecayDuration
            self.pitchSustainLevel = pitchSustainLevel
            self.pitchReleaseDuration = pitchReleaseDuration
            self.pitchADSRSemitones = pitchADSRSemitones
            self.glideRate = glideRate
            self.loopThruRelease = loopThruRelease
            self.isMonophonic = isMonophonic
            self.isLegato = isLegato
            self.keyTrackingFraction = keyTracking
            self.filterEnvelopeVelocityScaling = filterEnvelopeVelocityScaling
        }
    }

    open func loadAKAudioFile(from sampleDescriptor: AKSampleDescriptor, file: AKAudioFile) {
        let sampleRate = Float(file.sampleRate)
        let sampleCount = Int32(file.samplesCount)
        let channelCount = Int32(file.channelCount)
        let flattened = Array(file.floatChannelData!.joined())
        let data = UnsafeMutablePointer<Float>(mutating: flattened)
        internalAU?.loadSampleData(from: AKSampleDataDescriptor(sampleDescriptor: sampleDescriptor,
                                                                sampleRate: sampleRate,
                                                                isInterleaved: false,
                                                                channelCount: channelCount,
                                                                sampleCount: sampleCount,
                                                                data: data) )
    }

    open func stopAllVoices() {
        internalAU?.stopAllVoices()
    }

    open func restartVoices() {
        internalAU?.restartVoices()
    }

    open func loadRawSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        internalAU?.loadSampleData(from: sampleDataDescriptor)
    }

    open func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        internalAU?.loadCompressedSampleFile(from: sampleFileDescriptor)
    }

    open func unloadAllSamples() {
        internalAU?.unloadAllSamples()
    }

    open func setNoteFrequency(noteNumber: MIDINoteNumber, frequency: Double) {
        internalAU?.setNoteFrequency(noteNumber: Int32(noteNumber), noteFrequency: Float(frequency))
    }

    open func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }

    open func buildKeyMap() {
        internalAU?.buildKeyMap()
    }

    open func setLoop(thruRelease: Bool) {
        internalAU?.setLoop(thruRelease: thruRelease)
    }

    open override func play(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity)
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
