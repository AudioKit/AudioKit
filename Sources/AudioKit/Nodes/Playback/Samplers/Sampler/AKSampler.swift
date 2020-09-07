// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Sampler
///
public class AKSampler: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSamplerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "AKss")

    // MARK: - Properties

    public var internalAU: AKAudioUnitType?

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
    open var vibratoDepth: AUValue = 0.0 {
        willSet {
            guard vibratoDepth != newValue else { return }
            internalAU?.vibratoDepth.value = newValue
        }
    }

    /// Vibrato speed (hz)
    open var vibratoFrequency: AUValue = 5.0 {
        willSet {
            guard vibratoFrequency != newValue else { return }
            internalAU?.vibratoFrequency.value = newValue
        }
    }

    /// Voice Vibrato amount (semitones)
    open var voiceVibratoDepth: AUValue = 0.0 {
        willSet {
            guard voiceVibratoDepth != newValue else { return }
            internalAU?.voiceVibratoDepth.value = newValue
        }
    }

    /// VoiceVibrato speed (hz)
    open var voiceVibratoFrequency: AUValue = 5.0 {
        willSet {
            guard voiceVibratoFrequency != newValue else { return }
            internalAU?.voiceVibratoFrequency.value = newValue
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

    /// Glide rate (seconds per octave)
    open var glideRate: AUValue = 0.0 {
        willSet {
            guard glideRate != newValue else { return }
            internalAU?.glideRate.value = newValue
        }
    }

    /// Amplitude attack duration (seconds)
    open var attackDuration: AUValue = 0.0 {
        willSet {
            guard attackDuration != newValue else { return }
            internalAU?.attackDuration.value = newValue
        }
    }

    /// Amplitude hold duration (seconds)
    open var holdDuration: AUValue = 0.0 {
        willSet {
            guard holdDuration != newValue else { return }
            internalAU?.holdDuration.value = newValue
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

    /// Amplitude Release Hold duration (seconds)
    open var releaseHoldDuration: AUValue = 0.0 {
        willSet {
            guard releaseHoldDuration != newValue else { return }
            internalAU?.releaseHoldDuration.value = newValue
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

    /// Pitch attack duration (seconds)
    open var pitchAttackDuration: AUValue = 0.0 {
        willSet {
            guard pitchAttackDuration != newValue else { return }
            internalAU?.pitchAttackDuration.value = newValue
        }
    }

    /// Pitch Decay duration (seconds)
    open var pitchDecayDuration: AUValue = 0.0 {
        willSet {
            guard pitchDecayDuration != newValue else { return }
            internalAU?.pitchDecayDuration.value = newValue
        }
    }

    /// Pitch sustain level (fraction)
    open var pitchSustainLevel: AUValue = 1.0 {
        willSet {
            guard pitchSustainLevel != newValue else { return }
            internalAU?.pitchSustainLevel.value = newValue
        }
    }

    /// Pitch Release duration (seconds)
    open var pitchReleaseDuration: AUValue = 0.0 {
        willSet {
            guard pitchReleaseDuration != newValue else { return }
            internalAU?.pitchReleaseDuration.value = newValue
        }
    }

    /// Pitch EG Amount duration (semitones)
    open var pitchADSRSemitones: AUValue = 0.0 {
        willSet {
            guard pitchADSRSemitones != newValue else { return }
            internalAU?.pitchADSRSemitones.value = newValue
        }
    }

    /// Voice LFO restart (boolean, 0.0 for false or 1.0 for true) - resets the phase of each voice lfo on keydown
    public var restartVoiceLFO: Bool = false {
        willSet {
            guard restartVoiceLFO != newValue else { return }
            internalAU?.restartVoiceLFO.value = newValue ? 1.0 : 0.0
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
    open var keyTrackingFraction: AUValue = 1.0 {
        willSet {
            guard keyTrackingFraction != newValue else { return }
            internalAU?.keyTrackingFraction.value = newValue
        }
    }

    /// filterEnvelopeVelocityScaling (fraction 0.0 to 1.0)
    open var filterEnvelopeVelocityScaling: AUValue = 0.0 {
        willSet {
            guard filterEnvelopeVelocityScaling != newValue else { return }
            internalAU?.filterEnvelopeVelocityScaling.value = newValue
        }
    }

    // MARK: - Initialization

    /// Initialize this sampler node. There are many parameters, change them after initialization
    ///
    public init(sampleDescriptor: AKSampleDescriptor, file: AVAudioFile) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }
        self.loadAudioFile(from: sampleDescriptor, file: file)
    }

    /// Initialize this sampler node. There are many parameters, change them after initialization
    ///
    public init(sfzURL: URL) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }
        self.loadSFZ(url: sfzURL)
    }

    /// Initialize this sampler node. There are many parameters, change them after initialization
    ///
    public init(sfzPath: String, sfzFileName: String) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }
        self.loadSFZ(path: sfzPath, fileName: sfzFileName)
    }

    internal func loadAudioFile(from sampleDescriptor: AKSampleDescriptor, file: AVAudioFile) {
        guard let floatChannelData = file.toFloatChannelData() else { return }

        let sampleRate = Float(file.fileFormat.sampleRate)
        let sampleCount = Int32(file.length)
        let channelCount = Int32(file.fileFormat.channelCount)
        var flattened = Array(floatChannelData.joined())

        flattened.withUnsafeMutableBufferPointer { data in
            internalAU?.loadSampleData(from: AKSampleDataDescriptor(sampleDescriptor: sampleDescriptor,
                                                                    sampleRate: sampleRate,
                                                                    isInterleaved: false,
                                                                    channelCount: channelCount,
                                                                    sampleCount: sampleCount,
                                                                    data: data.baseAddress) )
        }
    }

    public func stopAllVoices() {
        internalAU?.stopAllVoices()
    }

    public func restartVoices() {
        internalAU?.restartVoices()
    }

    public func loadRawSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        internalAU?.loadSampleData(from: sampleDataDescriptor)
    }

    public func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        internalAU?.loadCompressedSampleFile(from: sampleFileDescriptor)
    }

    public func unloadAllSamples() {
        internalAU?.unloadAllSamples()
    }

    public func setNoteFrequency(noteNumber: MIDINoteNumber, frequency: AUValue) {
        internalAU?.setNoteFrequency(noteNumber: Int32(noteNumber), noteFrequency: frequency)
    }

    public func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }

    public func buildKeyMap() {
        internalAU?.buildKeyMap()
    }

    public func setLoop(thruRelease: Bool) {
        internalAU?.setLoop(thruRelease: thruRelease)
    }

    public override func play(noteNumber: MIDINoteNumber,
                              velocity: MIDIVelocity,
                              channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity)
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
