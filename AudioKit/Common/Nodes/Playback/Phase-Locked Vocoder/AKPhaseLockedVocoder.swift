// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is a phase locked vocoder. It has the ability to play back an audio
/// file loaded into an ftable like a sampler would. Unlike a typical sampler,
/// mincer allows time and pitch to be controlled separately.
///
open class AKPhaseLockedVocoder: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "minc")

    public typealias AKAudioUnitType = AKPhaseLockedVocoderAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Position
    public static let positionRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Pitch Ratio
    public static let pitchRatioRange: ClosedRange<AUValue> = 0 ... 1_000

    /// Initial value for Position
    public static let defaultPosition: AUValue = 0

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 1

    /// Initial value for Pitch Ratio
    public static let defaultPitchRatio: AUValue = 1

    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    public var position = AKNodeParameter(identifier: "position")

    /// Amplitude.
    public var amplitude = AKNodeParameter(identifier: "amplitude")

    /// Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    public var pitchRatio = AKNodeParameter(identifier: "pitchRatio")

    // MARK: - Initialization

    /// Initialize this vocoder node
    ///
    /// - Parameters:
    ///   - position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    ///   - amplitude: Amplitude.
    ///   - pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    public init(
        position: AUValue = defaultPosition,
        amplitude: AUValue = defaultAmplitude,
        pitchRatio: AUValue = defaultPitchRatio
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.position.associate(with: self.internalAU, value: position)
            self.amplitude.associate(with: self.internalAU, value: amplitude)
            self.pitchRatio.associate(with: self.internalAU, value: pitchRatio)

        }
    }
    /// Function create an identical new node for use in creating polyphonic instruments
    public func copy() -> AKPhaseLockedVocoder {
        let copy = AKPhaseLockedVocoder(position: self.position.value,
                                        amplitude: self.amplitude.value,
                                        pitchRatio: self.pitchRatio.value)
        return copy
    }
}
