// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKHighPassButterworthFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "bthp")

    public typealias AKAudioUnitType = AKHighPassButterworthFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Cutoff frequency. (in Hertz)
    @Parameter public var cutoffFrequency: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 500.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.cutoffFrequency = cutoffFrequency
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
