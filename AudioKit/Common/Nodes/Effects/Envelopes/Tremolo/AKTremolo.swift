// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Table-lookup tremolo with linear interpolation
///
open class AKTremolo: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "trem")

    public typealias AKAudioUnitType = AKTremoloAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Frequency (Hz)
    @Parameter public var frequency: AUValue

    /// Depth (0 - 1)
    @Parameter public var depth: AUValue

    // MARK: - Initialization

    /// Initialize this tremolo node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///   - waveform: Shape of the tremolo curve
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = 10,
        depth: AUValue = 1,
        waveform: AKTable = AKTable(.positiveSine)
    ) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.depth = depth

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setWavetable(waveform.content)

            input?.connect(to: self)
        }
    }
}
