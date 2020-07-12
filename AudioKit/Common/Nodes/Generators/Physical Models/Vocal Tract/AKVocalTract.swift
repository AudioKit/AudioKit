// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Based on the Pink Trombone algorithm by Neil Thapen, this implements a
/// physical model of the vocal tract glottal pulse wave. The tract model is
/// based on the classic Kelly-Lochbaum segmented cylindrical 1d waveguide
/// model, and the glottal pulse wave is a LF glottal pulse model.
///
open class AKVocalTract: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "vocw")

    public typealias AKAudioUnitType = AKVocalTractAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Glottal frequency.
    @Parameter public var frequency: AUValue

    /// Tongue position (0-1)
    @Parameter public var tonguePosition: AUValue

    /// Tongue diameter (0-1)
    @Parameter public var tongueDiameter: AUValue

    /// Vocal tenseness. 0 = all breath. 1=fully saturated.
    @Parameter public var tenseness: AUValue

    /// Sets the velum size. Larger values of this creates more nasally sounds.
    @Parameter public var nasality: AUValue

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
        frequency: AUValue = 160.0,
        tonguePosition: AUValue = 0.5,
        tongueDiameter: AUValue = 1.0,
        tenseness: AUValue = 0.6,
        nasality: AUValue = 0.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.frequency = frequency
        self.tonguePosition = tonguePosition
        self.tongueDiameter = tongueDiameter
        self.tenseness = tenseness
        self.nasality = nasality

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

    }
}
