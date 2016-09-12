//
//  AKTester.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Testing node
open class AKTester: AKNode, AKToggleable {

    // MARK: - Properties

    fileprivate var internalAU: AKTesterAudioUnit?
    fileprivate var testedNode: AKToggleable?
    fileprivate var token: AUParameterObserverToken?
    var totalSamples = 0

    /// Calculate the MD5
    open var MD5: String {
        return (self.internalAU?.getMD5())!
    }

    /// Flag on whether or not the test is still in progress
    open var isStarted: Bool {
        return Int((self.internalAU?.getSamples())!) < totalSamples
    }

    // MARK: - Initializers

    /// Initialize this test node
    ///
    /// - Parameters:
    ///   - input: AKNode to test
    ///   - sample: Number of sample to product
    ///
    public init(_ input: AKNode, samples: Int) {

        testedNode = input as? AKToggleable
        totalSamples = samples

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = fourCC("tstr")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKTesterAudioUnit.self,
            as: description,
            name: "Local AKTester",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKTesterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU?.setSamples(Int32(samples))
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        testedNode?.start()
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
