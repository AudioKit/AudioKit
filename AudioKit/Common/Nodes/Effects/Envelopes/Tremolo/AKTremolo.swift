// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Table-lookup tremolo with linear interpolation
///
open class AKTremolo: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "trem")

    public typealias AKAudioUnitType = AKTremoloAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0.0 ... 100.0

    /// Lower and upper bounds for Depth
    public static let depthRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 10.0

    /// Initial value for Depth
    public static let defaultDepth: AUValue = 1.0

    /// Frequency (Hz)
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Depth
    public let depth = AKNodeParameter(identifier: "depth")

    // MARK: - Initialization

    /// Initialize this tremolo node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = defaultFrequency,
        depth: AUValue = defaultDepth,
        waveform: AKTable = AKTable(.positiveSine)
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.depth.associate(with: self.internalAU, value: depth)

            self.internalAU?.setWavetable(waveform.content)

            input?.connect(to: self)
        }
    }
}
