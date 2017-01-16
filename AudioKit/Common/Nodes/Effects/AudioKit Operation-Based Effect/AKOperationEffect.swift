//
//  AKOperationEffect.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Operation-based effect
open class AKOperationEffect: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKOperationEffectAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "cstm")

    // MARK: - Properties

    fileprivate var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    /// Parameters for changing internal operations
    open var parameters: [Double] {
        get {
            return (internalAU?.parameters as? [NSNumber]).flatMap {
                $0.flatMap { $0.doubleValue }
            } ?? []
        }
        set {
            internalAU?.parameters = newValue
        }
    }

    // MARK: - Initializers
    
    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - input:            AKNode to use for processing
    ///   - numberOfChannels: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations:       Array of operations [left, right]
    ///
    public convenience init(_ input: AKNode,
                              numberOfChannels: Int,
                              operations: (AKStereoOperation, [AKOperation])->[AKOperation]) {
        
        let computedParameters = operations(AKStereoOperation.input, AKOperation.parameters)
        let left = computedParameters[0]
        
        if numberOfChannels == 2 {
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
                              operation: (AKStereoOperation, [AKOperation])->AKComputedParameter) {
        

        let computedParameter = operation(AKStereoOperation.input, AKOperation.parameters)
        
        if type(of: computedParameter) == AKOperation.self {
            let monoOperation = computedParameter as! AKOperation
            self.init(input, sporth: monoOperation.sporth + " dup ")
        } else {
            let stereoOperation = computedParameter as! AKStereoOperation
            self.init(input, sporth: stereoOperation.sporth + " swap ")
        }
    }
    

    /// Initialize the effect with an input and a valid Sporth string
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - sporth: String of valid Sporth code
    ///
    public init(_ input: AKNode, sporth: String) {

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self)
            self.internalAU?.setSporth(sporth)
        }
    }
    

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU!.stop()
    }
}
