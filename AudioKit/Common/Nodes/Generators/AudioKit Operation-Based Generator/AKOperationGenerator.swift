//
//  AKOperationGenerator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Operation-based generator
public class AKOperationGenerator: AKNode, AKToggleable {

    // MARK: - Properties

    private var internalAU: AKOperationGeneratorAudioUnit?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    public var sporth: String = "" {
        didSet  {
            self.stop()
            self.internalAU?.setSporth(sporth)
            self.start()
        }
    }

    /// Parameters for changing internal operations
    public var parameters: [Double] {
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
    
    /// Initialize with a mono or stereo operation
    ///
    /// - parameter operation: Operation to generate, can be mono or stereo
    ///
    public convenience init(operation: ([AKOperation])->AKComputedParameter) {
            
        let computedParameter = operation(AKOperation.parameters)
        
        if computedParameter.dynamicType == AKOperation.self {
            let monoOperation = computedParameter as! AKOperation
            self.init(sporth: monoOperation.sporth + " dup ")
        } else {
            let stereoOperation = computedParameter as! AKStereoOperation
            self.init(sporth: stereoOperation.sporth + " swap ")
        }
    }

    /// Initialize the generator for stereo (2 channels)
    ///
    /// - Parameters:
    ///   - numberOfChannels: Only 2 channels are supported, but need to differentiate the initializer
    ///   - operations:       Array of operations [left, right]
    ///
    public convenience init(numberOfChannels: Int, operations: ([AKOperation])->[AKOperation]) {
        
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
    public init(sporth: String) {

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = fourCC("cstg")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOperationGeneratorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKOperationGenerator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKOperationGeneratorAudioUnit
            AudioKit.engine.attachNode(self.avAudioNode)
            self.internalAU?.setSporth(sporth)
        }
    }

    /// Trigger the sound with current parameters
    ///
    public func trigger(triggerNumber: Int = 0) {
        self.internalAU!.trigger(Int32(triggerNumber))
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
