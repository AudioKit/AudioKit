// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Operation-based generator
public class OperationGenerator: Node {

    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode

    internal static func makeParam(_ number: Int) -> NodeParameterDef {
        return NodeParameterDef(
            identifier: "parameter\(number)",
            name: "Parameter \(number)",
            address: akGetParameterAddress("OperationParameter\(number)"),
            defaultValue: 0,
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
    @Parameter(parameter1Def) public var parameter1: AUValue
    /// Operation parameter 2
    @Parameter(parameter2Def) public var parameter2: AUValue
    /// Operation parameter 3
    @Parameter(parameter3Def) public var parameter3: AUValue
    /// Operation parameter 4
    @Parameter(parameter4Def) public var parameter4: AUValue
    /// Operation parameter 5
    @Parameter(parameter5Def) public var parameter5: AUValue
    /// Operation parameter 6
    @Parameter(parameter6Def) public var parameter6: AUValue
    /// Operation parameter 7
    @Parameter(parameter7Def) public var parameter7: AUValue
    /// Operation parameter 8
    @Parameter(parameter8Def) public var parameter8: AUValue
    /// Operation parameter 9
    @Parameter(parameter9Def) public var parameter9: AUValue
    /// Operation parameter 10
    @Parameter(parameter10Def) public var parameter10: AUValue
    /// Operation parameter 11
    @Parameter(parameter11Def) public var parameter11: AUValue
    /// Operation parameter 12
    @Parameter(parameter12Def) public var parameter12: AUValue
    /// Operation parameter 13
    @Parameter(parameter13Def) public var parameter13: AUValue
    /// Operation parameter 14
    @Parameter(parameter14Def) public var parameter14: AUValue

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

        avAudioNode = instantiate(generator: "cstg")
        setupParameters()
        
        akOperationSetSporth(au.dsp, sporth)
    }

    /// Trigger the sound with current parameters
    open func trigger() {
        au.trigger()
    }

}
