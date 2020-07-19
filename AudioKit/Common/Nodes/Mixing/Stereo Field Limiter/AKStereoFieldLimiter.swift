// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo StereoFieldLimiter
///
public class AKStereoFieldLimiter: AKNode, AKToggleable, AKComponent, AKInput {

    public static let ComponentDescription = AudioComponentDescription(effect: "sflm")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Properties

    static let amounDef = AKNodeParameterDef(
        identifier: "amount",
        name: "Limiting amount",
        address: 0,
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Limiting Factor
    @Parameter public var amount: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKStereoFieldLimiter.amounDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createStereoFieldLimiterDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - amount: limit factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: AKNode? = nil, amount: AUValue = 1) {
        super.init(avAudioNode: AVAudioNode())
        self.amount = amount

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)
        }
    }
}
