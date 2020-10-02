// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Operation-based generator
public class OperationGenerator: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Internal audio unit type
    public typealias AudioUnitType = InternalAU

    /// Four letter unique description "cstg"
    public static let ComponentDescription = AudioComponentDescription(generator: "cstg")

    // MARK: - Properties

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Parameters

    internal static func makeParam(_ number: Int) -> NodeParameterDef {
        return NodeParameterDef(
            identifier: "parameter\(number)",
            name: "Parameter \(number)",
            address: akGetParameterAddress("OperationGeneratorParameter\(number)"),
            range: floatRange,
            unit: .generic,
            flags: .default)
    }
    /// Specification for Parameter 1
    public static let parameter1Def = OperationGenerator.makeParam(1)
    /// Specification for Parameter 2
    public static let parameter2Def = OperationGenerator.makeParam(2)
    /// Specification for Parameter 3
    public static let parameter3Def = OperationGenerator.makeParam(3)
    /// Specification for Parameter 4
    public static let parameter4Def = OperationGenerator.makeParam(4)
    /// Specification for Parameter 5
    public static let parameter5Def = OperationGenerator.makeParam(5)
    /// Specification for Parameter 6
    public static let parameter6Def = OperationGenerator.makeParam(6)
    /// Specification for Parameter 7
    public static let parameter7Def = OperationGenerator.makeParam(7)
    /// Specification for Parameter 8
    public static let parameter8Def = OperationGenerator.makeParam(8)
    /// Specification for Parameter 9
    public static let parameter9Def = OperationGenerator.makeParam(9)
    /// Specification for Parameter 10
    public static let parameter10Def = OperationGenerator.makeParam(10)
    /// Specification for Parameter 11
    public static let parameter11Def = OperationGenerator.makeParam(11)
    /// Specification for Parameter 12
    public static let parameter12Def = OperationGenerator.makeParam(12)
    /// Specification for Parameter 13
    public static let parameter13Def = OperationGenerator.makeParam(13)
    /// Specification for Parameter 14
    public static let parameter14Def = OperationGenerator.makeParam(14)

    /// Operation parameter 1
    @Parameter public var parameter1: AUValue
    /// Operation parameter 2
    @Parameter public var parameter2: AUValue
    /// Operation parameter 3
    @Parameter public var parameter3: AUValue
    /// Operation parameter 4
    @Parameter public var parameter4: AUValue
    /// Operation parameter 5
    @Parameter public var parameter5: AUValue
    /// Operation parameter 6
    @Parameter public var parameter6: AUValue
    /// Operation parameter 7
    @Parameter public var parameter7: AUValue
    /// Operation parameter 8
    @Parameter public var parameter8: AUValue
    /// Operation parameter 9
    @Parameter public var parameter9: AUValue
    /// Operation parameter 10
    @Parameter public var parameter10: AUValue
    /// Operation parameter 11
    @Parameter public var parameter11: AUValue
    /// Operation parameter 12
    @Parameter public var parameter12: AUValue
    /// Operation parameter 13
    @Parameter public var parameter13: AUValue
    /// Operation parameter 14
    @Parameter public var parameter14: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for Operation Generator
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
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

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("OperationGeneratorDSP")
        }

        /// Trigger the operation generator
        public override func trigger() {
            akOperationGeneratorTrigger(dsp)
        }

        /// Set sporth string
        /// - Parameter sporth: Sporth string
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

    /// Initialize with a operation that takes no arguments
    ///
    /// - parameter operation: Operation to generate
    ///
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
    open func trigger() {
        internalAU?.trigger()
    }
}
