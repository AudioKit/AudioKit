// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// The output for reson appears to be very hot, so take caution when using this
/// module.
///
public class AKResonantFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "resn")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Center frequency of the filter, or frequency position of the peak response.",
        address: AKResonantFilterParameter.frequency.rawValue,
        range: 100.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency of the filter, or frequency position of the peak response.
    @Parameter public var frequency: AUValue

    public static let bandwidthDef = AKNodeParameterDef(
        identifier: "bandwidth",
        name: "Bandwidth of the filter.",
        address: AKResonantFilterParameter.bandwidth.rawValue,
        range: 0.0 ... 10_000.0,
        unit: .hertz,
        flags: .default)

    /// Bandwidth of the filter.
    @Parameter public var bandwidth: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKResonantFilter.frequencyDef,
                    AKResonantFilter.bandwidthDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createResonantFilterDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Center frequency of the filter, or frequency position of the peak response.
    ///   - bandwidth: Bandwidth of the filter.
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = 4_000.0,
        bandwidth: AUValue = 1_000.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.bandwidth = bandwidth
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
