//
//  AKOperationEffect.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Operation-based effect
open class AKOperationEffect: AKNode, AKToggleable {

    // MARK: - Properties

    fileprivate var internalAU: AKOperationEffectAudioUnit?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    /// Parameters for changing internal operations
    open var parameters: [Double] {
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

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = fourCC("cstm")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOperationEffectAudioUnit.self,
            as: description,
            name: "Local AKOperationEffect",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKOperationEffectAudioUnit
            AudioKit.engine.attach(self.avAudioNode)
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
