// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Sampler
public class Sampler: PolyphonicNode, AudioUnitContainer {
    /// Unique four-letter identifier "samp"
    public static let ComponentDescription = AudioComponentDescription(instrument: "samp")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = SamplerAudioUnit

    // MARK: - Properties

    /// Internal audio unit
    public var internalAU: AudioUnitType?

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

    /// Initialize this sampler node for one file. There are many parameters, change them after initialization
    ///
    /// - Parameters:
    ///   - sampleDescriptor: File describing how the audio file should be used
    ///   - file: Audio file to use for sample
    public init(sampleDescriptor: SampleDescriptor, file: AVAudioFile) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }
        self.loadAudioFile(from: sampleDescriptor, file: file)
    }

    /// A type to hold file with its sample descriptor
    public typealias FileWithSampleDescriptor = (sampleDescriptor: SampleDescriptor, file: AVAudioFile)

    /// Initialize this sampler node with many files. There are many parameters, change them after initialization
    ///
    /// - Parameters:
    ///   - filesWSampleDescriptors: An array of sample descriptors and files
    public init(filesWithSampleDescriptors: [FileWithSampleDescriptor]) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }

        for fileWithSampleDescriptor in filesWithSampleDescriptors {
            self.loadAudioFile(from: fileWithSampleDescriptor.sampleDescriptor, file: fileWithSampleDescriptor.file)
        }
    }

    /// Initialize this sampler node with an SFZ style file. There are many parameters, change them after initialization
    ///
    /// - Parameter sfzURL: URL of the SFZ sound font file
    public init(sfzURL: URL) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }
        self.loadSFZ(url: sfzURL)
    }

    /// Initialize this sampler node with SFZ path and file name. There are many parameters, change them after initialization
    ///
    /// - Parameters:
    ///   - sfzPath: Path to SFZ file
    ///   - sfzFileName: Name of SFZ file
    public init(sfzPath: String, sfzFileName: String) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }
        self.loadSFZ(path: sfzPath, fileName: sfzFileName)
    }

    internal func loadAudioFile(from sampleDescriptor: SampleDescriptor, file: AVAudioFile) {
        guard let floatChannelData = file.toFloatChannelData() else { return }

        let sampleRate = Float(file.fileFormat.sampleRate)
        let sampleCount = Int32(file.length)
        let channelCount = Int32(file.fileFormat.channelCount)
        var flattened = Array(floatChannelData.joined())

        flattened.withUnsafeMutableBufferPointer { data in
            internalAU?.loadSampleData(from: SampleDataDescriptor(sampleDescriptor: sampleDescriptor,
                                                                    sampleRate: sampleRate,
                                                                    isInterleaved: false,
                                                                    channelCount: channelCount,
                                                                    sampleCount: sampleCount,
                                                                    data: data.baseAddress) )
        }
    }

    /// Stop all voices
    public func stopAllVoices() {
        internalAU?.stopAllVoices()
    }

    /// Restart voices
    public func restartVoices() {
        internalAU?.restartVoices()
    }

    /// Load data from sample descriptor
    /// - Parameter sampleDataDescriptor: Sample descriptor information
    public func loadRawSampleData(from sampleDataDescriptor: SampleDataDescriptor) {
        internalAU?.loadSampleData(from: sampleDataDescriptor)
    }

    /// Load data from compressed file
    /// - Parameter sampleFileDescriptor: Sample descriptor information
    public func loadCompressedSampleFile(from sampleFileDescriptor: SampleFileDescriptor) {
        internalAU?.loadCompressedSampleFile(from: sampleFileDescriptor)
    }

    /// Unload all the samples from memory
    public func unloadAllSamples() {
        internalAU?.unloadAllSamples()
    }

    /// Assign a note number to a particular frequency
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - frequency: Frequency in Hertz
    public func setNoteFrequency(noteNumber: MIDINoteNumber, frequency: AUValue) {
        internalAU?.setNoteFrequency(noteNumber: Int32(noteNumber), noteFrequency: frequency)
    }

    /// Create a simple key map
    public func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }

    /// Build key map
    public func buildKeyMap() {
        internalAU?.buildKeyMap()
    }

    /// Set Loop
    /// - Parameter thruRelease: Wether or not to loop before or after the release
    public func setLoop(thruRelease: Bool) {
        internalAU?.setLoop(thruRelease: thruRelease)
    }

    /// Play the sampler
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: Velocity of the note
    ///   - channel: MIDI Channel
    public override func play(noteNumber: MIDINoteNumber,
                              velocity: MIDIVelocity,
                              channel: MIDIChannel = 0) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity)
    }

    /// Stop the sampler playback of a specific note
    /// - Parameter noteNumber: MIDI Note number
    public override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: false)
    }

    /// Stop and immediately silence a note
    /// - Parameter noteNumber: MIDI note number
    public func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: true)
    }

    /// Activate the sustain pedal
    /// - Parameter pedalDown: Wether the pedal is down (activated)
    public func sustainPedal(pedalDown: Bool) {
        internalAU?.sustainPedal(down: pedalDown)
    }

    // TODO This node is untested
}
