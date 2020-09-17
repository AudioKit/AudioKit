// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Operation-based generator
public class OperationGenerator: Node, AudioUnitContainer, Toggleable {
    public typealias AudioUnitType = InternalAU
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "cstg")

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
        address: akGetParameterAddress("OperationGeneratorParameter1"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter2Def = NodeParameterDef(
        identifier: "parameter2",
        name: "Parameter 2",
        address: akGetParameterAddress("OperationGeneratorParameter2"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter3Def = NodeParameterDef(
        identifier: "parameter3",
        name: "Parameter 3",
        address: akGetParameterAddress("OperationGeneratorParameter3"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter4Def = NodeParameterDef(
        identifier: "parameter4",
        name: "Parameter 4",
        address: akGetParameterAddress("OperationGeneratorParameter4"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter5Def = NodeParameterDef(
        identifier: "parameter5",
        name: "Parameter 5",
        address: akGetParameterAddress("OperationGeneratorParameter5"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter6Def = NodeParameterDef(
        identifier: "parameter6",
        name: "Parameter 6",
        address: akGetParameterAddress("OperationGeneratorParameter6"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter7Def = NodeParameterDef(
        identifier: "parameter7",
        name: "Parameter 7",
        address: akGetParameterAddress("OperationGeneratorParameter7"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter8Def = NodeParameterDef(
        identifier: "parameter8",
        name: "Parameter 8",
        address: akGetParameterAddress("OperationGeneratorParameter8"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter9Def = NodeParameterDef(
        identifier: "parameter9",
        name: "Parameter 9",
        address: akGetParameterAddress("OperationGeneratorParameter9"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter10Def = NodeParameterDef(
        identifier: "parameter10",
        name: "Parameter 10",
        address: akGetParameterAddress("OperationGeneratorParameter10"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter11Def = NodeParameterDef(
        identifier: "parameter11",
        name: "Parameter 11",
        address: akGetParameterAddress("OperationGeneratorParameter11"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter12Def = NodeParameterDef(
        identifier: "parameter12",
        name: "Parameter 12",
        address: akGetParameterAddress("OperationGeneratorParameter12"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter13Def = NodeParameterDef(
        identifier: "parameter13",
        name: "Parameter 13",
        address: akGetParameterAddress("OperationGeneratorParameter13"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter14Def = NodeParameterDef(
        identifier: "parameter14",
        name: "Parameter 14",
        address: akGetParameterAddress("OperationGeneratorParameter14"),
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
            [OperationGenerator.parameter1Def,
             OperationGenerator.parameter2Def,
             OperationGenerator.parameter3Def,
             OperationGenerator.parameter4Def,
             OperationGenerator.parameter5Def,
             OperationGenerator.parameter6Def,
             OperationGenerator.parameter7Def,
             OperationGenerator.parameter8Def,
             OperationGenerator.parameter9Def,
             OperationGenerator.parameter10Def,
             OperationGenerator.parameter11Def,
             OperationGenerator.parameter12Def,
             OperationGenerator.parameter13Def,
             OperationGenerator.parameter14Def]
        }

        public override func createDSP() -> DSPRef {
            akCreateDSP("OperationGeneratorDSP")
        }

        public func trigger(_ triggerNumber: Int) {
            akOperationGeneratorTrigger(dsp)
        }

        public func setSporth(_ sporth: String) {
            sporth.withCString { str -> Void in
                akOperationGeneratorSetSporth(dsp, str, Int32(sporth.utf8CString.count))
            }
        }
    }

    // MARK: - Initializers

    /// Initialize with a mono or stereo operation
    ///
    /// - parameter operation: Operation to generate, can be mono or stereo
    ///
    public convenience init(operation: ([Operation]) -> ComputedParameter) {

        let computedParameter = operation(Operation.parameters)

        if type(of: computedParameter) == Operation.self {
            if let monoOperation = computedParameter as? Operation {
                self.init(sporth: monoOperation.sporth + " dup ")
                return
            }
        } else {
            if let stereoOperation = computedParameter as? StereoOperation {
                self.init(sporth: stereoOperation.sporth + " swap ")
                return
            }
        }
        Log("Operation initialization failed.")
        self.init(sporth: "")
    }
    
    public convenience init(operation: () -> ComputedParameter) {
        self.init(operation: { _ in operation() })
    }

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - channelCount: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations: Array of operations [left, right]
    ///
    public convenience init(channelCount: Int, operations: ([Operation]) -> [Operation]) {

        let computedParameters = operations(Operation.parameters)
        let left = computedParameters[0]

        if channelCount == 2 {
            let right = computedParameters[1]
            self.init(sporth: "\(right.sporth) \(left.sporth)")
        } else {
            self.init(sporth: "\(left.sporth)")
        }
    }

    /// Initialize this generator node with a generic sporth stack and a triggering flag
    ///
    /// - parameter sporth: String of valid Sporth code
    ///
    public init(sporth: String = "") {

        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in

            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
            self.internalAU?.setSporth(sporth)
        }
    }

    /// Trigger the sound with current parameters
    ///
    open func trigger(_ triggerNumber: Int = 0) {
        internalAU?.trigger(triggerNumber)
    }
}
