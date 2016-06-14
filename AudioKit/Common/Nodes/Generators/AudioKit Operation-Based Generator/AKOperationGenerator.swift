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

    /// Parameters for changing internal operations
    public var parameters: [Double] = [] {
        didSet {
            internalAU?.setParameters(parameters)
        }
    }

    // MARK: - Initializers

    /// Initialize the generator with an operation and indicate whether it responds to a trigger
    ///
    /// - parameter operation: AKOperation stack to use
    ///
    public convenience init(operation: AKOperation) {
        let operationString = "\(operation) dup"
        self.init(operationString)
    }

    /// Initialize the generator with a stereo operation and indicate whether it responds to a trigger
    ///
    /// - parameter stereoOperation: AKStereoOperation stack to use
    ///
    public convenience init(stereoOperation: AKStereoOperation) {
        let operationString = "\(stereoOperation) swap"
        self.init(operationString)
    }

    /// Initialize the generator with a two mono operations for the left and right channel and indicate whether it responds to a trigger
    ///
    /// - parameter left: AKOperation to be heard from the left output
    /// - parameter right: AKOperation to be heard from the right output
    ///
    public convenience init(left: AKOperation, right: AKOperation) {
        let operationString = "\(right) \(left)"
        self.init(operationString)
    }

    /// Initialize this generator node with a generic sporth stack and a triggering flag
    ///
    /// - parameter sporth: String of valid Sporth code
    ///
    public init(_ sporth: String) {

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x63737467 /*'cstg'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOperationGeneratorAudioUnit.self,
            as: description,
            name: "Local AKOperationGenerator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKOperationGeneratorAudioUnit
            AudioKit.engine.attach(self.avAudioNode)
            self.internalAU?.setSporth(sporth)
        }
    }
    
    /// Trigger the sound with current parameters
    ///
    public func trigger() {
        self.internalAU!.trigger(self.parameters)
    }
    

    /// Trigger the sound with a set of parameters
    /// - parameter parameters: An array of doubles to use as parameters
    ///
    public func trigger(_ parameters: [Double]) {
        self.parameters = parameters
        self.internalAU!.trigger(parameters)
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
