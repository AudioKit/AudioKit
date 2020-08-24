// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Operation-based generator
public class AKOperationGenerator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = InternalAU
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "cstg")

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
        address: akGetParameterAddress("AKOperationGeneratorParameter1"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter2Def = AKNodeParameterDef(
        identifier: "parameter2",
        name: "Parameter 2",
        address: akGetParameterAddress("AKOperationGeneratorParameter2"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter3Def = AKNodeParameterDef(
        identifier: "parameter3",
        name: "Parameter 3",
        address: akGetParameterAddress("AKOperationGeneratorParameter3"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter4Def = AKNodeParameterDef(
        identifier: "parameter4",
        name: "Parameter 4",
        address: akGetParameterAddress("AKOperationGeneratorParameter4"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter5Def = AKNodeParameterDef(
        identifier: "parameter5",
        name: "Parameter 5",
        address: akGetParameterAddress("AKOperationGeneratorParameter5"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter6Def = AKNodeParameterDef(
        identifier: "parameter6",
        name: "Parameter 6",
        address: akGetParameterAddress("AKOperationGeneratorParameter6"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter7Def = AKNodeParameterDef(
        identifier: "parameter7",
        name: "Parameter 7",
        address: akGetParameterAddress("AKOperationGeneratorParameter7"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter8Def = AKNodeParameterDef(
        identifier: "parameter8",
        name: "Parameter 8",
        address: akGetParameterAddress("AKOperationGeneratorParameter8"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter9Def = AKNodeParameterDef(
        identifier: "parameter9",
        name: "Parameter 9",
        address: akGetParameterAddress("AKOperationGeneratorParameter9"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter10Def = AKNodeParameterDef(
        identifier: "parameter10",
        name: "Parameter 10",
        address: akGetParameterAddress("AKOperationGeneratorParameter10"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter11Def = AKNodeParameterDef(
        identifier: "parameter11",
        name: "Parameter 11",
        address: akGetParameterAddress("AKOperationGeneratorParameter11"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter12Def = AKNodeParameterDef(
        identifier: "parameter12",
        name: "Parameter 12",
        address: akGetParameterAddress("AKOperationGeneratorParameter12"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter13Def = AKNodeParameterDef(
        identifier: "parameter13",
        name: "Parameter 13",
        address: akGetParameterAddress("AKOperationGeneratorParameter13"),
        range: floatRange,
        unit: .generic,
        flags: .default)
    public static let parameter14Def = AKNodeParameterDef(
        identifier: "parameter14",
        name: "Parameter 14",
        address: akGetParameterAddress("AKOperationGeneratorParameter14"),
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
            [AKOperationGenerator.parameter1Def,
             AKOperationGenerator.parameter2Def,
             AKOperationGenerator.parameter3Def,
             AKOperationGenerator.parameter4Def,
             AKOperationGenerator.parameter5Def,
             AKOperationGenerator.parameter6Def,
             AKOperationGenerator.parameter7Def,
             AKOperationGenerator.parameter8Def,
             AKOperationGenerator.parameter9Def,
             AKOperationGenerator.parameter10Def,
             AKOperationGenerator.parameter11Def,
             AKOperationGenerator.parameter12Def,
             AKOperationGenerator.parameter13Def,
             AKOperationGenerator.parameter14Def]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKOperationGeneratorDSP")
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
    public convenience init(operation: ([AKOperation]) -> AKComputedParameter) {

        let computedParameter = operation(AKOperation.parameters)

        if type(of: computedParameter) == AKOperation.self {
            if let monoOperation = computedParameter as? AKOperation {
                self.init(sporth: monoOperation.sporth + " dup ")
                return
            }
        } else {
            if let stereoOperation = computedParameter as? AKStereoOperation {
                self.init(sporth: stereoOperation.sporth + " swap ")
                return
            }
        }
        AKLog("Operation initialization failed.")
        self.init(sporth: "")
    }
    
    public convenience init(operation: () -> AKComputedParameter) {
        self.init(operation: { _ in operation() })
    }

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - channelCount: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations: Array of operations [left, right]
    ///
    public convenience init(channelCount: Int, operations: ([AKOperation]) -> [AKOperation]) {

        let computedParameters = operations(AKOperation.parameters)
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
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.internalAU?.setSporth(sporth)
        }
    }

    /// Trigger the sound with current parameters
    ///
    open func trigger(_ triggerNumber: Int = 0) {
        internalAU?.trigger(triggerNumber)
    }
}
