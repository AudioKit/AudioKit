// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Operation-based effect
open class AKOperationEffect: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKOperationEffectAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "cstm")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    /// Parameters for changing internal operations
    @objc open dynamic var parameters: [Double] {
        get {
            return (internalAU?.parameters as? [NSNumber]).flatMap {
                $0.compactMap { $0.doubleValue }
            } ?? []
        }
        set {
            internalAU?.parameters = newValue
        }
    }

    private var customUgens: [AKCustomUgen]

    // MARK: - Initializers

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - channelCount: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations: Array of operations [left, right]
    ///
    public convenience init(_ input: AKNode?,
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
    public convenience init(_ input: AKNode?,
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

    /// Initialize the effect with an input and a valid Sporth string
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - sporth: String of valid Sporth code
    ///
    @objc public init(_ input: AKNode?, sporth: String, customUgens: [AKCustomUgen] = []) {
        self.customUgens = customUgens

        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self)
            for ugen in self.customUgens {
                self.internalAU?.add(ugen)
            }
            self.internalAU?.setSporth(sporth)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
