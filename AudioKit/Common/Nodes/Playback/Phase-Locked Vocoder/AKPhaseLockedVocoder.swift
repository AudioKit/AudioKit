// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is a phase locked vocoder. It has the ability to play back an audio
/// file loaded into an ftable like a sampler would. Unlike a typical sampler,
/// mincer allows time and pitch to be controlled separately.
///
open class AKPhaseLockedVocoder: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "minc")

    public typealias AKAudioUnitType = AKPhaseLockedVocoderAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    @Parameter public var position: AUValue

    /// Amplitude.
    @Parameter public var amplitude: AUValue

    /// Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    @Parameter public var pitchRatio: AUValue

    // MARK: - Initialization

    /// Initialize this vocoder node
    ///
    /// - Parameters:
    ///   - position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    ///   - amplitude: Amplitude.
    ///   - pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    public init(
        position: AUValue = 0,
        amplitude: AUValue = 1,
        pitchRatio: AUValue = 1
        ) {
        super.init(avAudioNode: AVAudioNode())

        self.position = position
        self.amplitude = amplitude
        self.pitchRatio = pitchRatio

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

        }
    }
    /// Function create an identical new node for use in creating polyphonic instruments
    public func copy() -> AKPhaseLockedVocoder {
        let copy = AKPhaseLockedVocoder(position: position, amplitude: amplitude, pitchRatio: pitchRatio)
        return copy
    }
}
