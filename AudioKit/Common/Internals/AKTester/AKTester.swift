//
//  AKTester.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/30/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation


public class AKTester: AKNode {

    // MARK: - Properties

    private var internalAU: AKTesterAudioUnit?
    private var token: AUParameterObserverToken?
    var totalSamples = 0

    // MARK: - Initializers

    public func getMD5() -> String {
        return (self.internalAU?.getMD5())!
    }
    
    public func isTesting() -> Bool {
        return Int((self.internalAU?.getSamples())!) < totalSamples
    }
    
    /** Initialize this test node */
    public init(_ input: AKNode, samples: Int) {
        super.init()
        
        totalSamples = samples

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x336c3466 /*'testr'*/ // Temp Change Hex Later
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKTesterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKTester",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKTesterAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
            self.internalAU?.setSamples(Int32(samples))
        }

        guard let tree = internalAU?.parameterTree else { return }


        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
            }
        }

    }
}
