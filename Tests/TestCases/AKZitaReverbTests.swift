//
//  AKZitaReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
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
        AKTestMD5("8910ee130583a9702c5eb27c65ef09a3")
    }

    func testParametersSetAfterInit() {
        let effect = AKZitaReverb(input)
        effect.rampDuration = 0
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
        AKTestMD5("b824be4839f14474fb80eca60da317f7")
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

        AKTestMD5("b824be4839f14474fb80eca60da317f7")
    }

}
