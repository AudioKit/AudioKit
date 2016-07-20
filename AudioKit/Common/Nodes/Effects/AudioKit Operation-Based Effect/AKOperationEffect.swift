//
//  AKOperationEffect.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Operation-based effect
public class AKOperationEffect: AKNode, AKToggleable {

    // MARK: - Properties

    private var internalAU: AKOperationEffectAudioUnit?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
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

    /// Initialize the effect with an input and separate operations for each channel
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - left: AKOperation stack to use on the left
    ///   - right: AKOperation stack to use on the right
    ///
    public convenience init(_ input: AKNode, left: AKOperation, right: AKOperation) {
        self.init(input, sporth:"\(right.sporth) \(left.sporth)")
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
        description.componentSubType      = 0x6373746d /*'cstm'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOperationEffectAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKOperationEffect",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKOperationEffectAudioUnit
            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU?.setSporth(sporth)
        }
    }

    /// Initialize the effect with an input and a valid Sporth string
    ///
    /// - Parameters:
    ///   - input: AKNode to use for processing
    ///   - sporth: String of valid Sporth code
    ///
    public init(_ input: AKNode, operation: ()->AKComputedParameter) {
        
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6373746d /*'cstm'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0
        
        AUAudioUnit.registerSubclass(
            AKOperationEffectAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKOperationEffect",
            version: UInt32.max)
        
        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in
            
            guard let avAudioUnitEffect = avAudioUnit else { return }
            
            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKOperationEffectAudioUnit
            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            let computedParameter = operation()
            
            if computedParameter.dynamicType == AKOperation.self {
                let monoOperation = computedParameter as! AKOperation
                self.internalAU?.setSporth(monoOperation.sporth + " dup ")
            }
            if computedParameter.dynamicType == AKStereoOperation.self {
                let stereoOperation = computedParameter as! AKStereoOperation
                self.internalAU?.setSporth(stereoOperation.sporth + " swap ")
            }
        }
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalAU!.stop()
    }
}
