//
//  AKOperationGenerator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Operation-based generator
open class AKOperationGenerator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKOperationGeneratorAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "cstg")

    // MARK: - Properties

    fileprivate var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    /// Sporth language snippet
    open dynamic var sporth: String = "" {
        didSet {
            restart()
        }
    }

    /// Parameters for changing internal operations
    open dynamic var parameters: [Double] {
        get {
            var result: [Double] = []
            if let floatParameters = internalAU?.parameters as? [NSNumber] {
                for number in floatParameters {
                    result.append(number.doubleValue)
                }
            }
            return result
        }
        set {
            internalAU?.parameters = newValue
        }
    }

    private var customUgens: [AKCustomUgen]

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

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - numberOfChannels: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations:       Array of operations [left, right]
    ///
    public convenience init(numberOfChannels: Int, operations: ([AKOperation]) -> [AKOperation]) {

        let computedParameters = operations(AKOperation.parameters)
        let left = computedParameters[0]

        if numberOfChannels == 2 {
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
    public init(sporth: String, customUgens: [AKCustomUgen] = []) {
        self.sporth = sporth
        self.customUgens = customUgens

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            for ugen in self?.customUgens ?? [] {
              self?.internalAU?.add(ugen)
            }
            self?.internalAU?.setSporth(sporth)
        }
    }

    /// Trigger the sound with current parameters
    ///
    open func trigger(_ triggerNumber: Int = 0) {
        internalAU?.trigger(Int32(triggerNumber))
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
