//
//  AKSampler.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo Chorus
///
open class AKSampler: AKPolyphonicNode, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKSamplerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "AKss")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var masterVolumeParameter: AUParameter?
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var filterCutoffParameter: AUParameter?
    fileprivate var filterEgStrengthParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?

    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?

    fileprivate var filterEnableParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Master volume (fraction)
    @objc open dynamic var masterVolume: Double = 1.0 {
        willSet {
            if masterVolume == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && masterVolumeParameter != nil {
                    masterVolumeParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.masterVolume = newValue
        }
    }

    /// Pitch offset (semitones)
    @objc open dynamic var pitchBend: Double = 0.0 {
        willSet {
            if pitchBend == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && pitchBendParameter != nil {
                    pitchBendParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.pitchBend = newValue
        }
    }

    /// Vibrato amount (semitones)
    @objc open dynamic var vibratoDepth: Double = 1.0 {
        willSet {
            if vibratoDepth == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && vibratoDepthParameter != nil {
                    vibratoDepthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.vibratoDepth = newValue
        }
    }

    /// Filter cutoff (harmonic ratio)
    @objc open dynamic var filterCutoff: Double = 4.0 {
        willSet {
            if filterCutoff == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && filterCutoffParameter != nil {
                    filterCutoffParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.filterCutoff = newValue
        }
    }

    /// Filter EG strength (harmonic ratio)
    @objc open dynamic var filterEgStrength: Double = 20.0 {
        willSet {
            if filterEgStrength == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && filterEgStrengthParameter != nil {
                    filterEgStrengthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.filterEgStrength = newValue
        }
    }

    /// Filter resonance (dB)
    @objc open dynamic var filterResonance: Double = 0.0 {
        willSet {
            if filterResonance == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && filterResonanceParameter != nil {
                    filterResonanceParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.filterResonance = newValue
        }
    }

    /// Amplitude attack duration (seconds)
    @objc open dynamic var attackDuration: Double = 0.0 {
        willSet {
            if attackDuration != newValue {
                internalAU?.attackDuration = newValue
            }
        }
    }

    /// Amplitude Decay duration (seconds)
    @objc open dynamic var decayDuration: Double = 0.0 {
        willSet {
            if decayDuration != newValue {
                internalAU?.decayDuration = newValue
            }
        }
    }

    /// Amplitude sustain level (fraction)
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                internalAU?.sustainLevel = newValue
            }
        }
    }

    /// Amplitude Release duration (seconds)
    @objc open dynamic var releaseDuration: Double = 0.0 {
        willSet {
            if releaseDuration != newValue {
                internalAU?.releaseDuration = newValue
            }
        }
    }

    /// Filter attack duration (seconds)
    @objc open dynamic var filterAttackDuration: Double = 0.0 {
        willSet {
            if filterAttackDuration != newValue {
                internalAU?.filterAttackDuration = newValue
            }
        }
    }

    /// Filter Decay duration (seconds)
    @objc open dynamic var filterDecayDuration: Double = 0.0 {
        willSet {
            if filterDecayDuration != newValue {
                internalAU?.filterDecayDuration = newValue
            }
        }
    }

    /// Filter sustain level (fraction)
    @objc open dynamic var filterSustainLevel: Double = 1.0 {
        willSet {
            if filterSustainLevel != newValue {
                internalAU?.filterSustainLevel = newValue
            }
        }
    }

    /// Filter Release duration (seconds)
    @objc open dynamic var filterReleaseDuration: Double = 0.0 {
        willSet {
            if filterReleaseDuration != newValue {
                internalAU?.filterReleaseDuration = newValue
            }
        }
    }

    /// Filter Enable (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var filterEnable: Bool = false {
        willSet {
            if filterEnable != newValue {
                internalAU?.filterEnable = newValue ? 1.0 : 0.0
            }
        }
    }

    // MARK: - Initialization

    /// Initialize this sampler node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed (not used)
    ///   - masterVolume: 0.0 - 1.0
    ///   - pitchBend: semitones, signed
    ///   - vibratoDepth: semitones, typically less than 1.0
    ///   - filterCutoff: relative to sample playback pitch, 1.0 = fundamental, 2.0 = 2nd harmonic etc
    ///   - filterEgStrength: same units as filterCutoff; amount filter EG adds to filterCutoff
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
        _ input: AKNode? = nil,
        masterVolume: Double = 1.0,
        pitchBend: Double = 0.0,
        vibratoDepth: Double = 0.0,
        filterCutoff: Double = 4.0,
        filterEgStrength: Double = 20.0,
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
        self.filterEgStrength = filterEgStrength
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

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        self.masterVolumeParameter = tree["masterVolume"]
        self.pitchBendParameter = tree["pitchBend"]
        self.vibratoDepthParameter = tree["vibratoDepth"]
        self.filterCutoffParameter = tree["filterCutoff"]
        self.filterEgStrengthParameter = tree["filterEgStrength"]
        self.filterResonanceParameter = tree["filterResonance"]
        self.attackDurationParameter = tree["attackDuration"]
        self.decayDurationParameter = tree["decayDuration"]
        self.sustainLevelParameter = tree["sustainLevel"]
        self.releaseDurationParameter = tree["releaseDuration"]
        self.filterAttackDurationParameter = tree["filterAttackDuration"]
        self.filterDecayDurationParameter = tree["filterDecayDuration"]
        self.filterSustainLevelParameter = tree["filterSustainLevel"]
        self.filterReleaseDurationParameter = tree["filterReleaseDuration"]
        self.filterEnableParameter = tree["filterEnable"]

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

        self.internalAU?.setParameterImmediately(.masterVolume, value: masterVolume)
        self.internalAU?.setParameterImmediately(.pitchBend, value: pitchBend)
        self.internalAU?.setParameterImmediately(.vibratoDepth, value: vibratoDepth)
        self.internalAU?.setParameterImmediately(.filterCutoff, value: filterCutoff)
        self.internalAU?.setParameterImmediately(.filterEgStrength, value: filterEgStrength)
        self.internalAU?.setParameterImmediately(.filterResonance, value: filterResonance)
        self.internalAU?.setParameterImmediately(.attackDuration, value: attackDuration)
        self.internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
        self.internalAU?.setParameterImmediately(.sustainLevel, value: sustainLevel)
        self.internalAU?.setParameterImmediately(.releaseDuration, value: releaseDuration)
        self.internalAU?.setParameterImmediately(.filterAttackDuration, value: filterAttackDuration)
        self.internalAU?.setParameterImmediately(.filterDecayDuration, value: filterDecayDuration)
        self.internalAU?.setParameterImmediately(.filterSustainLevel, value: filterSustainLevel)
        self.internalAU?.setParameterImmediately(.filterReleaseDuration, value: filterReleaseDuration)
        self.internalAU?.setParameterImmediately(.filterEnable, value: filterEnable ? 1.0 : 0.0)
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

    open func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }

    open func buildKeyMap() {
        internalAU?.buildKeyMap()
    }

    open func setLoop(thruRelease: Bool) {
        internalAU?.setLoop(thruRelease: thruRelease)
    }

    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
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
