// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Based on the Pink Trombone algorithm by Neil Thapen, this implements a
/// physical model of the vocal tract glottal pulse wave. The tract model is
/// based on the classic Kelly-Lochbaum segmented cylindrical 1d waveguide
/// model, and the glottal pulse wave is a LF glottal pulse model.
///
open class AKVocalTract: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "vocw")

    public typealias AKAudioUnitType = AKVocalTractAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0.0 ... 22_050.0

    /// Lower and upper bounds for Tongue Position
    public static let tonguePositionRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Tongue Diameter
    public static let tongueDiameterRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Tenseness
    public static let tensenessRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Nasality
    public static let nasalityRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 160.0

    /// Initial value for Tongue Position
    public static let defaultTonguePosition: AUValue = 0.5

    /// Initial value for Tongue Diameter
    public static let defaultTongueDiameter: AUValue = 1.0

    /// Initial value for Tenseness
    public static let defaultTenseness: AUValue = 0.6

    /// Initial value for Nasality
    public static let defaultNasality: AUValue = 0.0

    /// Glottal frequency.
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Tongue position (0-1)
    public let tonguePosition = AKNodeParameter(identifier: "tonguePosition")

    /// Tongue diameter (0-1)
    public let tongueDiameter = AKNodeParameter(identifier: "tongueDiameter")

    /// Vocal tenseness. 0 = all breath. 1=fully saturated.
    public let tenseness = AKNodeParameter(identifier: "tenseness")

    /// Sets the velum size. Larger values of this creates more nasally sounds.
    public let nasality = AKNodeParameter(identifier: "nasality")

    // MARK: - Initialization

    /// Initialize this vocal tract node
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    public init(
        frequency: AUValue = defaultFrequency,
        tonguePosition: AUValue = defaultTonguePosition,
        tongueDiameter: AUValue = defaultTongueDiameter,
        tenseness: AUValue = defaultTenseness,
        nasality: AUValue = defaultNasality
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.tonguePosition.associate(with: self.internalAU, value: tonguePosition)
            self.tongueDiameter.associate(with: self.internalAU, value: tongueDiameter)
            self.tenseness.associate(with: self.internalAU, value: tenseness)
            self.nasality.associate(with: self.internalAU, value: nasality)
        }

    }
}
