//
//  AKSampler.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Sampler
///
@objc open class AKSampler: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSamplerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "AKss")

    // MARK: - Properties

    @objc public var internalAU: AKAudioUnitType?

    fileprivate var masterVolumeParameter: AUParameter?
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var vibratoFrequencyParameter: AUParameter?
    fileprivate var voiceVibratoDepthParameter: AUParameter?
    fileprivate var voiceVibratoFrequencyParameter: AUParameter?
    fileprivate var filterCutoffParameter: AUParameter?
    fileprivate var filterStrengthParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?
    fileprivate var glideRateParameter: AUParameter?

    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var holdDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseHoldDurationParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?

    fileprivate var pitchAttackDurationParameter: AUParameter?
    fileprivate var pitchDecayDurationParameter: AUParameter?
    fileprivate var pitchSustainLevelParameter: AUParameter?
    fileprivate var pitchReleaseDurationParameter: AUParameter?
    fileprivate var pitchADSRSemitonesParameter: AUParameter?

    fileprivate var filterEnableParameter: AUParameter?
    fileprivate var restartVoiceLFOParameter: AUParameter?
    fileprivate var loopThruReleaseParameter: AUParameter?
    fileprivate var monophonicParameter: AUParameter?
    fileprivate var legatoParameter: AUParameter?
    fileprivate var keyTrackingParameter: AUParameter?
    fileprivate var filterEnvelopeVelocityScalingParameter: AUParameter?

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
    @objc open dynamic var vibratoDepth: Double = 0.0 {
        willSet {
            guard vibratoDepth != newValue else { return }

            if internalAU?.isSetUp == true {
                vibratoDepthParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.vibratoDepth = newValue
        }
    }

    /// Vibrato speed (hz)
    @objc open dynamic var vibratoFrequency: Double = 5.0 {
        willSet {
            guard vibratoFrequency != newValue else { return }

            if internalAU?.isSetUp == true {
                vibratoFrequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.vibratoFrequency = newValue
        }
    }

    /// Voice Vibrato amount (semitones) - each voice behaves indpendently
    @objc open dynamic var voiceVibratoDepth: Double = 0.0 {
        willSet {
            guard voiceVibratoDepth != newValue else { return }

            if internalAU?.isSetUp == true {
                voiceVibratoDepthParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.voiceVibratoDepth = newValue
        }
    }

    /// Vibrato speed (hz)
    @objc open dynamic var voiceVibratoFrequency: Double = 5.0 {
        willSet {
            guard voiceVibratoFrequency != newValue else { return }

            if internalAU?.isSetUp == true {
                voiceVibratoFrequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.voiceVibratoFrequency = newValue
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

    /// Glide rate (seconds per octave)
    @objc open dynamic var glideRate: Double = 0.0 {
        willSet {
            guard glideRate != newValue else { return }

            if internalAU?.isSetUp == true {
                glideRateParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.glideRate = newValue
        }
    }

    /// Amplitude attack duration (seconds)
    @objc open dynamic var attackDuration: Double = 0.0 {
        willSet {
            guard attackDuration != newValue else { return }
            internalAU?.attackDuration = newValue
        }
    }

    /// Amplitude hold duration (seconds)
    @objc open dynamic var holdDuration: Double = 0.0 {
        willSet {
            guard holdDuration != newValue else { return }
            internalAU?.holdDuration = newValue
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

    /// Amplitude Release Hold duration (seconds)
    @objc open dynamic var releaseHoldDuration: Double = 0.0 {
        willSet {
            guard releaseHoldDuration != newValue else { return }
            internalAU?.releaseHoldDuration = newValue
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

    /// Pitch attack duration (seconds)
    @objc open dynamic var pitchAttackDuration: Double = 0.0 {
        willSet {
            guard pitchAttackDuration != newValue else { return }
            internalAU?.pitchAttackDuration = newValue
        }
    }

    /// Pitch Decay duration (seconds)
    @objc open dynamic var pitchDecayDuration: Double = 0.0 {
        willSet {
            guard pitchDecayDuration != newValue else { return }
            internalAU?.pitchDecayDuration = newValue
        }
    }

    /// Pitch sustain level (fraction)
    @objc open dynamic var pitchSustainLevel: Double = 1.0 {
        willSet {
            guard pitchSustainLevel != newValue else { return }
            internalAU?.pitchSustainLevel = newValue
        }
    }

    /// Pitch Release duration (seconds)
    @objc open dynamic var pitchReleaseDuration: Double = 0.0 {
        willSet {
            guard pitchReleaseDuration != newValue else { return }
            internalAU?.pitchReleaseDuration = newValue
        }
    }

    /// Pitch EG Amount duration (semitones)
    @objc open dynamic var pitchADSRSemitones: Double = 0.0 {
        willSet {
            guard pitchADSRSemitones != newValue else { return }
            internalAU?.pitchADSRSemitones = newValue
        }
    }

    /// Voice LFO restart (boolean, 0.0 for false or 1.0 for true) - resets the phase of each voice lfo on keydown
    @objc open dynamic var restartVoiceLFO: Bool = false {
        willSet {
            guard restartVoiceLFO != newValue else { return }
            internalAU?.restartVoiceLFO = newValue ? 1.0 : 0.0
        }
    }

    /// Filter Enable (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var filterEnable: Bool = false {
        willSet {
            guard filterEnable != newValue else { return }
            internalAU?.filterEnable = newValue ? 1.0 : 0.0
        }
    }

    /// Loop Thru Release (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var loopThruRelease: Bool = false {
        willSet {
            guard loopThruRelease != newValue else { return }
            internalAU?.loopThruRelease = newValue ? 1.0 : 0.0
        }
    }

    /// isMonophonic (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var isMonophonic: Bool = false {
        willSet {
            guard isMonophonic != newValue else { return }
            internalAU?.isMonophonic = newValue ? 1.0 : 0.0
        }
    }

    /// isLegato (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var isLegato: Bool = false {
        willSet {
            guard isLegato != newValue else { return }
            internalAU?.isLegato = newValue ? 1.0 : 0.0
        }
    }

    /// keyTrackingFraction (-2.0 to +2.0, normal range 0.0 to 1.0)
    @objc open dynamic var keyTrackingFraction: Double = 1.0 {
        willSet {
            guard keyTrackingFraction != newValue else { return }
            internalAU?.keyTrackingFraction = newValue
        }
    }

    /// filterEnvelopeVelocityScaling (fraction 0.0 to 1.0)
    @objc open dynamic var filterEnvelopeVelocityScaling: Double = 0.0 {
        willSet {
            guard filterEnvelopeVelocityScaling != newValue else { return }
            internalAU?.filterEnvelopeVelocityScaling = newValue
        }
    }

    // MARK: - Initialization

    /// Initialize this sampler node
    ///
    /// - Parameters:
    ///   - masterVolume: 0.0 - 1.0
    ///   - pitchBend: semitones, signed
    ///   - vibratoDepth: semitones, typically less than 1.0
    ///   - vibratoFrequency: hertz
    ///   - voiceVibratoDepth: semitones, typically less than 1.0
    ///   - voiceVibratoFrequency: hertz
    ///   - filterCutoff: relative to sample playback pitch, 1.0 = fundamental, 2.0 = 2nd harmonic etc
    ///   - filterStrength: same units as filterCutoff; amount filter EG adds to filterCutoff
    ///   - filterResonance: dB, -20.0 - 20.0
    ///   - attackDuration: seconds, 0.0 - 10.0
    ///   - holdDuration: seconds, 0.0 - 10.0
    ///   - decayDuration: seconds, 0.0 - 10.0
    ///   - sustainLevel: 0.0 - 1.0
    ///   - releaseHoldDuration: seconds, 0.0 - 10.0
    ///   - releaseDuration: seconds, 0.0 - 10.0
    ///   - restartVoiceLFO: true to reset each voice vibrato lfo on noteOn
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
    @objc public init(
        masterVolume: Double = 1.0,
        pitchBend: Double = 0.0,
        vibratoDepth: Double = 0.0,
        vibratoFrequency: Double = 5.0,
        voiceVibratoDepth: Double = 0.0,
        voiceVibratoFrequency: Double = 5.0,
        filterCutoff: Double = 4.0,
        filterStrength: Double = 20.0,
        filterResonance: Double = 0.0,
        attackDuration: Double = 0.0,
        holdDuration: Double = 0.0,
        decayDuration: Double = 0.0,
        sustainLevel: Double = 1.0,
        releaseHoldDuration: Double = 0.0,
        releaseDuration: Double = 0.0,
        restartVoiceLFO: Bool = false,
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
        filterEnvelopeVelocityScaling: Double = 0.0) {

        self.masterVolume = masterVolume
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.vibratoFrequency = vibratoFrequency
        self.voiceVibratoDepth = voiceVibratoDepth
        self.voiceVibratoFrequency = voiceVibratoFrequency
        self.filterCutoff = filterCutoff
        self.filterStrength = filterStrength
        self.filterResonance = filterResonance
        self.attackDuration = attackDuration
        self.holdDuration = holdDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseHoldDuration = releaseHoldDuration
        self.releaseDuration = releaseDuration
        self.restartVoiceLFO = restartVoiceLFO
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

        AKSampler.register()

        super.init()

        AVAudioUnit._instantiate(with: AKSampler.ComponentDescription) { [weak self] avAudioUnit in
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
        self.vibratoFrequencyParameter = tree["vibratoFrequency"]
        self.voiceVibratoDepthParameter = tree["voiceVibratoDepth"]
        self.voiceVibratoFrequencyParameter = tree["voiceVibratoFrequency"]
        self.filterCutoffParameter = tree["filterCutoff"]
        self.filterStrengthParameter = tree["filterStrength"]
        self.filterResonanceParameter = tree["filterResonance"]
        self.attackDurationParameter = tree["attackDuration"]
        self.holdDurationParameter = tree["holdDuration"]
        self.decayDurationParameter = tree["decayDuration"]
        self.sustainLevelParameter = tree["sustainLevel"]
        self.releaseHoldDurationParameter = tree["releaseHoldDuration"]
        self.releaseDurationParameter = tree["releaseDuration"]
        self.filterAttackDurationParameter = tree["filterAttackDuration"]
        self.filterDecayDurationParameter = tree["filterDecayDuration"]
        self.filterSustainLevelParameter = tree["filterSustainLevel"]
        self.filterReleaseDurationParameter = tree["filterReleaseDuration"]
        self.restartVoiceLFOParameter = tree["restartVoiceLFO"]
        self.filterEnableParameter = tree["filterEnable"]
        self.pitchAttackDurationParameter = tree["pitchAttackDuration"]
        self.pitchDecayDurationParameter = tree["pitchDecayDuration"]
        self.pitchSustainLevelParameter = tree["pitchSustainLevel"]
        self.pitchReleaseDurationParameter = tree["pitchReleaseDuration"]
        self.pitchADSRSemitonesParameter = tree["pitchADSRSemitones"]
        self.glideRateParameter = tree["glideRate"]
        self.loopThruReleaseParameter = tree["loopThruRelease"]
        self.monophonicParameter = tree["monophonic"]
        self.legatoParameter = tree["legato"]
        self.keyTrackingParameter = tree["keyTracking"]
        self.filterEnvelopeVelocityScalingParameter = tree["filterEnvelopeVelocityScaling"]

        self.internalAU?.setParameterImmediately(.masterVolume, value: masterVolume)
        self.internalAU?.setParameterImmediately(.pitchBend, value: pitchBend)
        self.internalAU?.setParameterImmediately(.vibratoDepth, value: vibratoDepth)
        self.internalAU?.setParameterImmediately(.vibratoFrequency, value: vibratoFrequency)
        self.internalAU?.setParameterImmediately(.voiceVibratoDepth, value: voiceVibratoDepth)
        self.internalAU?.setParameterImmediately(.voiceVibratoFrequency, value: voiceVibratoFrequency)
        self.internalAU?.setParameterImmediately(.filterCutoff, value: filterCutoff)
        self.internalAU?.setParameterImmediately(.filterStrength, value: filterStrength)
        self.internalAU?.setParameterImmediately(.filterResonance, value: filterResonance)
        self.internalAU?.setParameterImmediately(.attackDuration, value: attackDuration)
        self.internalAU?.setParameterImmediately(.holdDuration, value: holdDuration)
        self.internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
        self.internalAU?.setParameterImmediately(.sustainLevel, value: sustainLevel)
        self.internalAU?.setParameterImmediately(.releaseHoldDuration, value: releaseHoldDuration)
        self.internalAU?.setParameterImmediately(.releaseDuration, value: releaseDuration)
        self.internalAU?.setParameterImmediately(.filterAttackDuration, value: filterAttackDuration)
        self.internalAU?.setParameterImmediately(.filterDecayDuration, value: filterDecayDuration)
        self.internalAU?.setParameterImmediately(.filterSustainLevel, value: filterSustainLevel)
        self.internalAU?.setParameterImmediately(.filterReleaseDuration, value: filterReleaseDuration)
        self.internalAU?.setParameterImmediately(.filterEnable, value: filterEnable ? 1.0 : 0.0)
        self.internalAU?.setParameterImmediately(.restartVoiceLFO, value: restartVoiceLFO ? 1.0 : 0.0)
        self.internalAU?.setParameterImmediately(.pitchAttackDuration, value: pitchAttackDuration)
        self.internalAU?.setParameterImmediately(.pitchDecayDuration, value: pitchDecayDuration)
        self.internalAU?.setParameterImmediately(.pitchSustainLevel, value: pitchSustainLevel)
        self.internalAU?.setParameterImmediately(.pitchReleaseDuration, value: pitchReleaseDuration)
        self.internalAU?.setParameterImmediately(.pitchADSRSemitones, value: pitchADSRSemitones)
        self.internalAU?.setParameterImmediately(.glideRate, value: glideRate)
        self.internalAU?.setParameterImmediately(.loopThruRelease, value: loopThruRelease ? 1.0 : 0.0)
        self.internalAU?.setParameterImmediately(.monophonic, value: isMonophonic ? 1.0 : 0.0)
        self.internalAU?.setParameterImmediately(.legato, value: isLegato ? 1.0 : 0.0)
        self.internalAU?.setParameterImmediately(.keyTrackingFraction, value: keyTracking)
        self.internalAU?.setParameterImmediately(.filterEnvelopeVelocityScaling, value: filterEnvelopeVelocityScaling)
    }

    @objc open func loadAKAudioFile(from sampleDescriptor: AKSampleDescriptor, file: AKAudioFile) {
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

    @objc open func stopAllVoices() {
        internalAU?.stopAllVoices()
    }

    @objc open func restartVoices() {
        internalAU?.restartVoices()
    }

    @objc open func loadRawSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        internalAU?.loadSampleData(from: sampleDataDescriptor)
    }

    @objc open func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        internalAU?.loadCompressedSampleFile(from: sampleFileDescriptor)
    }

    @objc open func unloadAllSamples() {
        internalAU?.unloadAllSamples()
    }

    @objc open func setNoteFrequency(noteNumber: MIDINoteNumber, frequency: Double) {
        internalAU?.setNoteFrequency(noteNumber: Int32(noteNumber), noteFrequency: Float(frequency))
    }

    @objc open func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }

    @objc open func buildKeyMap() {
        internalAU?.buildKeyMap()
    }

    @objc open func setLoop(thruRelease: Bool) {
        internalAU?.setLoop(thruRelease: thruRelease)
    }

    @objc open override func play(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity)
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
