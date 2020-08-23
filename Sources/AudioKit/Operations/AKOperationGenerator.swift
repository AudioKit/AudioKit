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

    /// Sporth language snippet
    public var sporth: String = "" {
        didSet {
            restart()
        }
    }

        /// Parameters for changing internal operations
        public var parameters: [Float] {
            get {
                return []
            }
            set {
                internalAU?.setParameters(newValue)
            }
        }

        // MARK: - Audio Unit

        public class InternalAU: AKAudioUnitBase {

            public override func createDSP() -> AKDSPRef {
                akCreateDSP("AKOperationGeneratorDSP")
            }

            public func setParameters(_ params: [Float]) -> Void {
                var p = params
                akOperationGeneratorSetParameters(dsp, &p)
            }

            public func trigger(_ triggerNumber: Int) -> Void {
                akOperationGeneratorTrigger(dsp, Int32(triggerNumber))
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
        self.sporth = sporth

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

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }

    /// Restart from scratch
    open func restart() {
        stop()
        internalAU?.setSporth(sporth)
        start()
    }
}
