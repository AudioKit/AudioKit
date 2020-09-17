// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

let floatRange = -Float.greatestFiniteMagnitude ... Float.greatestFiniteMagnitude

/// Operation-based effect
public class OperationEffect: Node, AudioUnitContainer, Toggleable {
    public typealias AudioUnitType = InternalAU
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "cstm")

    // MARK: - Properties

    public private(set) var internalAU: AudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Parameters

    public static let parameter1Def = NodeParameterDef(
        identifier: "parameter1",
        name: "Parameter 1",
        address: akGetParameterAddress("OperationEffectParameter1"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter2Def = NodeParameterDef(
        identifier: "parameter2",
        name: "Parameter 2",
        address: akGetParameterAddress("OperationEffectParameter2"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter3Def = NodeParameterDef(
        identifier: "parameter3",
        name: "Parameter 3",
        address: akGetParameterAddress("OperationEffectParameter3"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter4Def = NodeParameterDef(
        identifier: "parameter4",
        name: "Parameter 4",
        address: akGetParameterAddress("OperationEffectParameter4"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter5Def = NodeParameterDef(
        identifier: "parameter5",
        name: "Parameter 5",
        address: akGetParameterAddress("OperationEffectParameter5"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter6Def = NodeParameterDef(
        identifier: "parameter6",
        name: "Parameter 6",
        address: akGetParameterAddress("OperationEffectParameter6"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter7Def = NodeParameterDef(
        identifier: "parameter7",
        name: "Parameter 7",
        address: akGetParameterAddress("OperationEffectParameter7"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter8Def = NodeParameterDef(
        identifier: "parameter8",
        name: "Parameter 8",
        address: akGetParameterAddress("OperationEffectParameter8"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter9Def = NodeParameterDef(
        identifier: "parameter9",
        name: "Parameter 9",
        address: akGetParameterAddress("OperationEffectParameter9"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter10Def = NodeParameterDef(
        identifier: "parameter10",
        name: "Parameter 10",
        address: akGetParameterAddress("OperationEffectParameter10"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter11Def = NodeParameterDef(
        identifier: "parameter11",
        name: "Parameter 11",
        address: akGetParameterAddress("OperationEffectParameter11"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter12Def = NodeParameterDef(
        identifier: "parameter12",
        name: "Parameter 12",
        address: akGetParameterAddress("OperationEffectParameter12"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter13Def = NodeParameterDef(
        identifier: "parameter13",
        name: "Parameter 13",
        address: akGetParameterAddress("OperationEffectParameter13"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter14Def = NodeParameterDef(
        identifier: "parameter14",
        name: "Parameter 14",
        address: akGetParameterAddress("OperationEffectParameter14"),
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

    public class InternalAU: AudioUnitBase {
        public override func getParameterDefs() -> [NodeParameterDef] {
            [OperationEffect.parameter1Def,
             OperationEffect.parameter2Def,
             OperationEffect.parameter3Def,
             OperationEffect.parameter4Def,
             OperationEffect.parameter5Def,
             OperationEffect.parameter6Def,
             OperationEffect.parameter7Def,
             OperationEffect.parameter8Def,
             OperationEffect.parameter9Def,
             OperationEffect.parameter10Def,
             OperationEffect.parameter11Def,
             OperationEffect.parameter12Def,
             OperationEffect.parameter13Def,
             OperationEffect.parameter14Def]
        }

        public override func createDSP() -> DSPRef {
            akCreateDSP("OperationEffectDSP")
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
    ///   - input: Node to use for processing
    ///   - channelCount: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations: Array of operations [left, right]
    ///
    public convenience init(_ input: Node,
                            channelCount: Int,
                            operations: (StereoOperation, [Operation]) -> [Operation]) {

        let computedParameters = operations(StereoOperation.input, Operation.parameters)
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
    ///   - input:     Node to use for processing
    ///   - operation: Operation to generate, can be mono or stereo
    ///
    public convenience init(_ input: Node,
                            operation: (StereoOperation, [Operation]) -> ComputedParameter) {

        let computedParameter = operation(StereoOperation.input, Operation.parameters)

        if type(of: computedParameter) == Operation.self {
            if let monoOperation = computedParameter as? Operation {
                self.init(input, sporth: monoOperation.sporth + " dup ")
                return
            }
        } else {
            if let stereoOperation = computedParameter as? StereoOperation {
                self.init(input, sporth: stereoOperation.sporth + " swap ")
                return
            }
        }
        Log("Initialization failed.")
        self.init(input, sporth: "")
    }

    public convenience init(_ input: Node, operation: (StereoOperation) -> ComputedParameter) {
        self.init(input, operation: { node, _ in operation(node) })
    }

    /// Initialize the effect with an input and a valid Sporth string
    ///
    /// - Parameters:
    ///   - input: Node to use for processing
    ///   - sporth: String of valid Sporth code
    ///
    public init(_ input: Node, sporth: String) {

        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.internalAU?.setSporth(sporth)
        }

        connections.append(input)
    }
}
