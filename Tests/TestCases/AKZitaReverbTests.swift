//
//  AKZitaReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 7/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKZitaReverbTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKZitaReverb(input)
        AKTestMD5("647f0ce4e5c5fea58da3a10601c2b43d")
    }

    func testParametersSetAfterInit() {
        let effect = AKZitaReverb(input)
        effect.predelay = 10
        effect.crossoverFrequency = 200
        effect.lowReleaseTime = 1.5
        effect.midReleaseTime = 1.0
        effect.dampingFrequency = 3_000
        effect.equalizerFrequency1 = 300
        effect.equalizerLevel1 = 1
        effect.equalizerFrequency2 = 1_400
        effect.equalizerLevel2 = -1
        effect.dryWetMix = 0.5
        output = effect
        AKTestMD5("14c0c89623979f31317b8df3b8713466")
    }

    func testParametersSetOnInit() {
        output = AKZitaReverb(input,
                              predelay: 10,
                              crossoverFrequency: 200,
                              lowReleaseTime: 1.5,
                              midReleaseTime: 1.0,
                              dampingFrequency: 3_000,
                              equalizerFrequency1: 300,
                              equalizerLevel1: 1,
                              equalizerFrequency2: 1_400,
                              equalizerLevel2: -1,
                              dryWetMix: 0.5)

        AKTestMD5("14c0c89623979f31317b8df3b8713466")
    }

}
