// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Sampler
public class Sampler: Node {

    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode = instantiate(instrument: "samp")

    // MARK: - Parameters

    private static var nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

    /// Specification details for master volume
    public static let masterVolumeDef = NodeParameterDef(
        identifier: "masterVolume",
        name: "Master Volume",
        address: akGetParameterAddress("SamplerParameterMasterVolume"),
        defaultValue: 1,
        range: 0.0 ... 1,
        unit: .generic)

    /// Master Volume (fraction)
    @Parameter(masterVolumeDef) public var masterVolume: AUValue

    /// Specification details for pitchBend
    public static let pitchBendDef = NodeParameterDef(
        identifier: "pitchBend",
        name: "Pitch bend (semitones)",
        address: akGetParameterAddress("SamplerParameterPitchBend"),
        defaultValue: 0.0,
        range: -24 ... 24,
        unit: .relativeSemiTones)

    /// Pitch offset (semitones)
    @Parameter(pitchBendDef) public var pitchBend: AUValue

    /// Specification details for vibratoDepth
    public static let vibratoDepthDef = NodeParameterDef(
        identifier: "vibratoDepth",
        name: "Vibrato Depth",
        address: akGetParameterAddress("SamplerParameterVibratoDepth"),
        defaultValue: 0.0,
        range: 0 ... 12,
        unit: .relativeSemiTones)

    /// Vibrato amount (semitones)
    @Parameter(vibratoDepthDef) public var vibratoDepth: AUValue

    /// Specification details for vibratoFrequency
    public static let vibratoFrequencyDef = NodeParameterDef(
        identifier: "vibratoFrequency",
        name: "Vibrato Speed (hz)",
        address: akGetParameterAddress("SamplerParameterVibratoFrequency"),
        defaultValue: 5.0,
        range: 0 ... 200,
        unit: .hertz)

    /// Vibrato speed (hz)
    @Parameter(vibratoFrequencyDef) public var vibratoFrequency: AUValue

    /// Specification details for voiceVibratoDepth
    public static let voiceVibratoDepthDef = NodeParameterDef(
        identifier: "voiceVibratoDepth",
        name: "Voice Vibrato (semitones)",
        address: akGetParameterAddress("SamplerParameterVoiceVibratoDepth"),
        defaultValue: 0.0,
        range: 0 ... 24,
        unit: .relativeSemiTones)

    /// Voice Vibrato amount (semitones)
    @Parameter(voiceVibratoDepthDef) public var voiceVibratoDepth: AUValue

    /// Specification details for voiceVibratoFrequency
    public static let voiceVibratoFrequencyDef = NodeParameterDef(
        identifier: "voiceVibratoFrequency",
        name: "Voice Vibrato speed (Hz)",
        address: akGetParameterAddress("SamplerParameterVoiceVibratoFrequency"),
        defaultValue: 5.0,
        range: 0 ... 200,
        unit: .hertz)

    /// Voice Vibrato speed (Hz)
    @Parameter(voiceVibratoFrequencyDef) public var voiceVibratoFrequency: AUValue

    /// Specification details for filterCutoff
    public static let filterCutoffDef = NodeParameterDef(
        identifier: "filterCutoff",
        name: "Filter Cutoff",
        address: akGetParameterAddress("SamplerParameterFilterCutoff"),
        defaultValue: 4.0,
        range: 1 ... 1000,
        unit: .rate)

    /// Filter cutoff (harmonic ratio)
    @Parameter(filterCutoffDef) public var filterCutoff: AUValue

    /// Specification details for filterStrength
    public static let filterStrengthDef = NodeParameterDef(
        identifier: "filterStrength",
        name: "Filter Strength",
        address: akGetParameterAddress("SamplerParameterFilterStrength"),
        defaultValue: 20,
        range: 1 ... 1000,
        unit: .ratio)

    /// filterStrength
    @Parameter(filterStrengthDef) public var filterStrength: AUValue

    /// Specification details for filterResonance
    public static let filterResonanceDef = NodeParameterDef(
        identifier: "filterResonance",
        name: "Filter Resonance",
        address: akGetParameterAddress("SamplerParameterFilterResonance"),
        defaultValue: 0,
        range: -20 ... 20,
        unit: .decibels)

    /// Filter resonance (dB)
    @Parameter(filterResonanceDef) public var filterResonance: AUValue

    /// Specification details for glideRate
    public static let glideRateDef = NodeParameterDef(
        identifier: "glideRate",
        name: "Glide rate (sec/octave))",
        address: akGetParameterAddress("SamplerParameterGlideRate"),
        defaultValue: 0,
        range: 0 ... 20,
        unit: .generic)

    /// Glide rate (seconds per octave)
    @Parameter(glideRateDef) public var glideRate: AUValue

    /// Specification details for attackDuration
    public static let attackDurationDef = NodeParameterDef(
        identifier: "attackDuration",
        name: "Attack Duration (s)",
        address: akGetParameterAddress("SamplerParameterAttackDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Amplitude attack duration (seconds)
    @Parameter(attackDurationDef) public var attackDuration: AUValue

    /// Specification details for holdDuration
    public static let holdDurationDef = NodeParameterDef(
        identifier: "holdDuration",
        name: "Hold Duration (s)",
        address: akGetParameterAddress("SamplerParameterHoldDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Amplitude hold duration (seconds)
    @Parameter(holdDurationDef) public var holdDuration: AUValue

    /// Specification details for decayDuration
    public static let decayDurationDef = NodeParameterDef(
        identifier: "decayDuration",
        name: "Decay Duration (s)",
        address: akGetParameterAddress("SamplerParameterDecayDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Amplitude decay duration (seconds)
    @Parameter(decayDurationDef) public var decayDuration: AUValue

    /// Specification details for sustainLevel
    public static let sustainLevelDef = NodeParameterDef(
        identifier: "sustainLevel",
        name: "Sustain Level",
        address: akGetParameterAddress("SamplerParameterSustainLevel"),
        defaultValue: 1,
        range: 0 ... 1,
        unit: .generic,
        flags: nonRampFlags)

    /// Amplitude sustain level (fraction)
    @Parameter(sustainLevelDef) public var sustainLevel: AUValue

    /// Specification details for releaseDuration
    public static let releaseDurationDef = NodeParameterDef(
        identifier: "releaseDuration",
        name: "Release Duration (s)",
        address: akGetParameterAddress("SamplerParameterReleaseDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Amplitude release duration (seconds)
    @Parameter(releaseDurationDef) public var releaseDuration: AUValue

    /// Specification details for filterAttackDuration
    public static let filterAttackDurationDef = NodeParameterDef(
        identifier: "filterAttackDuration",
        name: "Filter Attack Duration (s)",
        address: akGetParameterAddress("SamplerParameterFilterAttackDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Filter Amplitude attack duration (seconds)
    @Parameter(filterAttackDurationDef) public var filterAttackDuration: AUValue

    /// Specification details for filterDecayDuration
    public static let filterDecayDurationDef = NodeParameterDef(
        identifier: "filterDecayDuration",
        name: "Filter Decay Duration (s)",
        address: akGetParameterAddress("SamplerParameterFilterDecayDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Filter Amplitude decay duration (seconds)
    @Parameter(filterDecayDurationDef) public var filterDecayDuration: AUValue

    /// Specification details for filterSustainLevel
    public static let filterSustainLevelDef = NodeParameterDef(
        identifier: "filterSustainLevel",
        name: "Filter Sustain Level",
        address: akGetParameterAddress("SamplerParameterFilterSustainLevel"),
        defaultValue: 1,
        range: 0 ... 1,
        unit: .generic,
        flags: nonRampFlags)

    /// Filter Amplitude sustain level (fraction)
    @Parameter(filterSustainLevelDef) public var filterSustainLevel: AUValue

    /// Specification details for filterReleaseDuration
    public static let filterReleaseDurationDef = NodeParameterDef(
        identifier: "filterReleaseDuration",
        name: "Filter Release Duration (s)",
        address: akGetParameterAddress("SamplerParameterFilterReleaseDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Filter Amplitude release duration (seconds)
    @Parameter(filterReleaseDurationDef) public var filterReleaseDuration: AUValue

    /// Specification details for pitchAttackDuration
    public static let pitchAttackDurationDef = NodeParameterDef(
        identifier: "pitchAttackDuration",
        name: "Pitch Attack Duration (s)",
        address: akGetParameterAddress("SamplerParameterPitchAttackDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Pitch Amplitude attack duration (seconds)
    @Parameter(pitchAttackDurationDef) public var pitchAttackDuration: AUValue

    /// Specification details for pitchDecayDuration
    public static let pitchDecayDurationDef = NodeParameterDef(
        identifier: "pitchDecayDuration",
        name: "Pitch Decay Duration (s)",
        address: akGetParameterAddress("SamplerParameterPitchDecayDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds)

    /// Pitch Amplitude decay duration (seconds)
    @Parameter(pitchDecayDurationDef) public var pitchDecayDuration: AUValue

    /// Specification details for pitchSustainLevel
    public static let pitchSustainLevelDef = NodeParameterDef(
        identifier: "pitchSustainLevel",
        name: "Pitch Sustain Level",
        address: akGetParameterAddress("SamplerParameterPitchSustainLevel"),
        defaultValue: 1,
        range: 0 ... 1,
        unit: .generic,
        flags: nonRampFlags)

    /// Pitch Amplitude sustain level (fraction)
    @Parameter(pitchSustainLevelDef) public var pitchSustainLevel: AUValue

    /// Specification details for pitchReleaseDuration
    public static let pitchReleaseDurationDef = NodeParameterDef(
        identifier: "pitchReleaseDuration",
        name: "Pitch Release Duration (s)",
        address: akGetParameterAddress("SamplerParameterPitchReleaseDuration"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds,
        flags: nonRampFlags)

    /// Pitch Amplitude release duration (seconds)
    @Parameter(pitchReleaseDurationDef) public var pitchReleaseDuration: AUValue

    /// Specification details for pitchADSRSemitones
    public static let pitchADSRSemitonesDef = NodeParameterDef(
        identifier: "pitchADSRSemitones",
        name: "Pitch EG Amount duration (semitones)",
        address: akGetParameterAddress("SamplerParameterPitchADSRSemitones"),
        defaultValue: 0,
        range: 0 ... 12,
        unit: .seconds,
        flags: nonRampFlags)
    
    /// Pitch EG Amount duration (semitones)
    @Parameter(pitchADSRSemitonesDef) public var pitchADSRSemitones: AUValue
    
    /// Specification details for restartVoiceLFO
    public static let restartVoiceLFODef = NodeParameterDef(
        identifier: "restartVoiceLFO",
        name: "restartVoiceLFO",
        address: akGetParameterAddress("SamplerParameterRestartVoiceLFO"),
        defaultValue: 0,
        range: 0 ... 1,
        unit: .boolean,
        flags: nonRampFlags)
    
    /// Voice LFO restart (boolean, 0.0 for false or 1.0 for true) - resets the phase of each voice lfo on keydown
    @Parameter(restartVoiceLFODef) public var restartVoiceLFO: AUValue

    /// Specification details for filterEnable
    public static let filterEnableDef = NodeParameterDef(
        identifier: "filterEnable",
        name: "Filter Enable",
        address: akGetParameterAddress("SamplerParameterFilterEnable"),
        defaultValue: 0,
        range: 0 ... 1,
        unit: .boolean,
        flags: nonRampFlags)
    
    /// Enale Filter Flag
    @Parameter(filterEnableDef) public var filterEnable: AUValue
    
    /// Specification details for loopThruRelease
    public static let loopThruReleaseDef = NodeParameterDef(
        identifier: "loopThruRelease",
        name: "loopThruRelease",
        address: akGetParameterAddress("SamplerParameterLoopThruRelease"),
        defaultValue: 0,
        range: 0 ... 1,
        unit: .boolean,
        flags: nonRampFlags)
    
    /// Loop Thru Release (boolean, 0.0 for false or 1.0 for true)
    @Parameter(loopThruReleaseDef) public var loopThruRelease: AUValue

    /// Specification details for isMonophonic
    public static let isMonophonicDef = NodeParameterDef(
        identifier: "isMonophonic",
        name: "isMonophonic",
        address: akGetParameterAddress("SamplerParameterMonophonic"),
        defaultValue: 0,
        range: 0 ... 1,
        unit: .boolean,
        flags: nonRampFlags)

    /// isMonophonic (boolean, 0.0 for false or 1.0 for true)
    @Parameter(isMonophonicDef) public var isMonophonic: AUValue

    /// Specification details for isLegato
    public static let isLegatoDef = NodeParameterDef(
        identifier: "isLegato",
        name: "isLegato",
        address: akGetParameterAddress("SamplerParameterLegato"),
        defaultValue: 0,
        range: 0 ... 1,
        unit: .generic,
        flags: nonRampFlags)

    /// isLegato (boolean, 0.0 for false or 1.0 for true)
    @Parameter(isLegatoDef) public var isLegato: AUValue

    /// Specification details for keyTrackingFraction
    public static let keyTrackingFractionDef = NodeParameterDef(
        identifier: "keyTrackingFraction",
        name: "Key Tracking",
        address: akGetParameterAddress("SamplerParameterKeyTrackingFraction"),
        defaultValue: 1,
        range: -2 ... 2,
        unit: .generic,
        flags: nonRampFlags)

    /// keyTrackingFraction (-2.0 to +2.0, normal range 0.0 to 1.0)
    @Parameter(keyTrackingFractionDef) public var keyTrackingFraction: AUValue

    /// Specification details for filterEnvelopeVelocityScaling
    public static let filterEnvelopeVelocityScalingDef = NodeParameterDef(
        identifier: "filterEnvelopeVelocityScaling",
        name: "Filter Envelope Scaling",
        address: akGetParameterAddress("SamplerParameterFilterEnvelopeVelocityScaling"),
        defaultValue: 1,
        range: 0 ... 1,
        unit: .generic,
        flags: nonRampFlags)

    /// filterEnvelopeVelocityScaling (fraction 0.0 to 1.0)
    @Parameter(filterEnvelopeVelocityScalingDef) public var filterEnvelopeVelocityScaling: AUValue

    // MARK: - Initialization

    /// Initialize without any descriptors
    public init() {
        setupParameters()
    }

    /// Initialize this sampler node for one file. There are many parameters, change them after initialization
    ///
    /// - Parameters:
    ///   - sampleDescriptor: File describing how the audio file should be used
    ///   - file: Audio file to use for sample
    public convenience init(sampleDescriptor: SampleDescriptor, file: AVAudioFile) {
        self.init()
        self.loadAudioFile(from: sampleDescriptor, file: file)
    }

    /// A type to hold file with its sample descriptor
    public typealias FileWithSampleDescriptor = (sampleDescriptor: SampleDescriptor, file: AVAudioFile)

    /// Initialize this sampler node with many files. There are many parameters, change them after initialization
    ///
    /// - Parameters:
    ///   - filesWSampleDescriptors: An array of sample descriptors and files
    public convenience init(filesWithSampleDescriptors: [FileWithSampleDescriptor]) {
        self.init()

        for fileWithSampleDescriptor in filesWithSampleDescriptors {
            self.loadAudioFile(from: fileWithSampleDescriptor.sampleDescriptor, file: fileWithSampleDescriptor.file)
        }
    }

    /// Initialize this sampler node with an SFZ style file. There are many parameters, change them after initialization
    ///
    /// - Parameter sfzURL: URL of the SFZ sound font file
    public convenience init(sfzURL: URL) {
        self.init()
        self.loadSFZ(url: sfzURL)
    }

    /// Initialize this sampler node with SFZ path and file name. There are many parameters, change them after initialization
    ///
    /// - Parameters:
    ///   - sfzPath: Path to SFZ file
    ///   - sfzFileName: Name of SFZ file
    public convenience init(sfzPath: String, sfzFileName: String) {
        self.init()
        self.loadSFZ(path: sfzPath, fileName: sfzFileName)
    }

    internal func loadAudioFile(from sampleDescriptor: SampleDescriptor, file: AVAudioFile) {
        guard let floatChannelData = file.toFloatChannelData() else { return }

        let sampleRate = Float(file.fileFormat.sampleRate)
        let sampleCount = Int32(file.length)
        let channelCount = Int32(file.fileFormat.channelCount)
        var flattened = Array(floatChannelData.joined())

        flattened.withUnsafeMutableBufferPointer { data in

            var descriptor = SampleDataDescriptor(sampleDescriptor: sampleDescriptor,
                                                  sampleRate: sampleRate,
                                                  isInterleaved: false,
                                                  channelCount: channelCount,
                                                  sampleCount: sampleCount,
                                                  data: data.baseAddress)

            akSamplerLoadData(au.dsp, &descriptor)
        }
    }

    /// Stop all voices
    public func stopAllVoices() {
        akSamplerStopAllVoices(au.dsp)
    }

    /// Restart voices
    public func restartVoices() {
        akSamplerRestartVoices(au.dsp)
    }

    /// Load data from sample descriptor
    /// - Parameter sampleDataDescriptor: Sample descriptor information
    public func loadRawSampleData(from sampleDataDescriptor: SampleDataDescriptor) {
        var copy = sampleDataDescriptor
        akSamplerLoadData(au.dsp, &copy)
    }

    /// Load data from compressed file
    /// - Parameter sampleFileDescriptor: Sample descriptor information
    public func loadCompressedSampleFile(from sampleFileDescriptor: SampleFileDescriptor) {
        var copy = sampleFileDescriptor
        akSamplerLoadCompressedFile(au.dsp, &copy)
    }

    /// Unload all the samples from memory
    public func unloadAllSamples() {
        akSamplerUnloadAllSamples(au.dsp)
    }

    /// Assign a note number to a particular frequency
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - frequency: Frequency in Hertz
    public func setNoteFrequency(noteNumber: MIDINoteNumber, frequency: AUValue) {
        akSamplerSetNoteFrequency(au.dsp, Int32(noteNumber), frequency)
    }

    /// Create a simple key map
    public func buildSimpleKeyMap() {
        akSamplerBuildSimpleKeyMap(au.dsp)
    }

    /// Build key map
    public func buildKeyMap() {
        akSamplerBuildKeyMap(au.dsp)
    }

    /// Set Loop
    /// - Parameter thruRelease: Wether or not to loop before or after the release
    public func setLoop(thruRelease: Bool) {
        akSamplerSetLoopThruRelease(au.dsp, thruRelease)
    }

    /// Play the sampler
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: Velocity of the note
    ///   - channel: MIDI Channel
    public func play(noteNumber: MIDINoteNumber,
                     velocity: MIDIVelocity,
                     channel: MIDIChannel = 0) {
        akSamplerPlayNote(au.dsp, noteNumber, velocity)
    }

    /// Stop the sampler playback of a specific note
    /// - Parameter noteNumber: MIDI Note number
    public func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel = 0) {
        akSamplerStopNote(au.dsp, noteNumber, false)
    }

    /// Stop and immediately silence a note
    /// - Parameter noteNumber: MIDI note number
    public func silence(noteNumber: MIDINoteNumber) {
        akSamplerStopNote(au.dsp, noteNumber, true)
    }

    /// Activate the sustain pedal
    /// - Parameter pedalDown: Wether the pedal is down (activated)
    public func sustainPedal(pedalDown: Bool) {
        akSamplerSustainPedal(au.dsp, pedalDown)
    }

}
