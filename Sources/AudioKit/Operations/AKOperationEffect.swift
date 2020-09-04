// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

let floatRange = -Float.greatestFiniteMagnitude ... Float.greatestFiniteMagnitude

/// Operation-based effect
public class AKOperationEffect: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = InternalAU
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "cstm")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Parameters

    public static let parameter1Def = AKNodeParameterDef(
        identifier: "parameter1",
        name: "Parameter 1",
        address: akGetParameterAddress("AKOperationEffectParameter1"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter2Def = AKNodeParameterDef(
        identifier: "parameter2",
        name: "Parameter 2",
        address: akGetParameterAddress("AKOperationEffectParameter2"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter3Def = AKNodeParameterDef(
        identifier: "parameter3",
        name: "Parameter 3",
        address: akGetParameterAddress("AKOperationEffectParameter3"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter4Def = AKNodeParameterDef(
        identifier: "parameter4",
        name: "Parameter 4",
        address: akGetParameterAddress("AKOperationEffectParameter4"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter5Def = AKNodeParameterDef(
        identifier: "parameter5",
        name: "Parameter 5",
        address: akGetParameterAddress("AKOperationEffectParameter5"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter6Def = AKNodeParameterDef(
        identifier: "parameter6",
        name: "Parameter 6",
        address: akGetParameterAddress("AKOperationEffectParameter6"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter7Def = AKNodeParameterDef(
        identifier: "parameter7",
        name: "Parameter 7",
        address: akGetParameterAddress("AKOperationEffectParameter7"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter8Def = AKNodeParameterDef(
        identifier: "parameter8",
        name: "Parameter 8",
        address: akGetParameterAddress("AKOperationEffectParameter8"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter9Def = AKNodeParameterDef(
        identifier: "parameter9",
        name: "Parameter 9",
        address: akGetParameterAddress("AKOperationEffectParameter9"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter10Def = AKNodeParameterDef(
        identifier: "parameter10",
        name: "Parameter 10",
        address: akGetParameterAddress("AKOperationEffectParameter10"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter11Def = AKNodeParameterDef(
        identifier: "parameter11",
        name: "Parameter 11",
        address: akGetParameterAddress("AKOperationEffectParameter11"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter12Def = AKNodeParameterDef(
        identifier: "parameter12",
        name: "Parameter 12",
        address: akGetParameterAddress("AKOperationEffectParameter12"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter13Def = AKNodeParameterDef(
        identifier: "parameter13",
        name: "Parameter 13",
        address: akGetParameterAddress("AKOperationEffectParameter13"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter14Def = AKNodeParameterDef(
        identifier: "parameter14",
        name: "Parameter 14",
        address: akGetParameterAddress("AKOperationEffectParameter14"),
        range: floatRange,
        unit: .generic,
        flags: .default)

    @Parameter public var parameter1: AUValue
    @Parameter public var parameter2: AUValue
    @Parameter public var parameter3: AUValue
    @Parameter public var parameter4: AUValue
    @Parameter public var parameter5: AUValue
    @Parameter public var parameter6: AUValue
    @Parameter public var parameter7: AUValue
    @Parameter public var parameter8: AUValue
    @Parameter public var parameter9: AUValue
    @Parameter public var parameter10: AUValue
    @Parameter public var parameter11: AUValue
    @Parameter public var parameter12: AUValue
    @Parameter public var parameter13: AUValue
    @Parameter public var parameter14: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {
        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKOperationEffect.parameter1Def,
             AKOperationEffect.parameter2Def,
             AKOperationEffect.parameter3Def,
             AKOperationEffect.parameter4Def,
             AKOperationEffect.parameter5Def,
             AKOperationEffect.parameter6Def,
             AKOperationEffect.parameter7Def,
             AKOperationEffect.parameter8Def,
             AKOperationEffect.parameter9Def,
             AKOperationEffect.parameter10Def,
             AKOperationEffect.parameter11Def,
             AKOperationEffect.parameter12Def,
             AKOperationEffect.parameter13Def,
             AKOperationEffect.parameter14Def]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKOperationEffectDSP")
        }

        public func setSporth(_ sporth: String) {
            sporth.withCString { str -> Void in
                akOperationEffectSetSporth(dsp, str, Int32(sporth.utf8CString.count))
            }
        }
    }

    // MARK: - Initializers

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - channelCount: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations: Array of operations [left, right]
    ///
    public convenience init(_ input: AKNode,
                            channelCount: Int,
                            operations: (AKStereoOperation, [AKOperation]) -> [AKOperation]) {

        let computedParameters = operations(AKStereoOperation.input, AKOperation.parameters)
        let left = computedParameters[0]

        if channelCount == 2 {
            let right = computedParameters[1]
            self.init(input, sporth: "\(right.sporth) \(left.sporth)")
        } else {
            self.init(input, sporth: "\(left.sporth)")
        }
    }

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - input:     AKNode to use for processing
    ///   - operation: Operation to generate, can be mono or stereo
    ///
    public convenience init(_ input: AKNode,
                            operation: (AKStereoOperation, [AKOperation]) -> AKComputedParameter) {

        let computedParameter = operation(AKStereoOperation.input, AKOperation.parameters)

        if type(of: computedParameter) == AKOperation.self {
            if let monoOperation = computedParameter as? AKOperation {
                self.init(input, sporth: monoOperation.sporth + " dup ")
                return
            }
        } else {
            if let stereoOperation = computedParameter as? AKStereoOperation {
                self.init(input, sporth: stereoOperation.sporth + " swap ")
                return
            }
        }
        AKLog("Initialization failed.")
        self.init(input, sporth: "")
    }

    public convenience init(_ input: AKNode, operation: (AKStereoOperation) -> AKComputedParameter) {
        self.init(input, operation: { node, _ in operation(node) })
    }

    /// Initialize the effect with an input and a valid Sporth string
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - sporth: String of valid Sporth code
    ///
    public init(_ input: AKNode, sporth: String) {

        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.internalAU?.setSporth(sporth)
        }

        connections.append(input)
    }
}
