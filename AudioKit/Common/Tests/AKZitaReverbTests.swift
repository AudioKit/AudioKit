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
        let input = AKOscillator()
        output = AKZitaReverb(input)
        input.start()
        AKTestMD5("db8e3a4acca377528667c3babbd80bbe")
    }

    func testParametersSetOnInit() {
        let input = AKOscillator()
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

        input.start()
        AKTestMD5("699a91ae893b3899a2f4711f7edca067")
    }

    func testParametersSetAfterInit() {
        let input = AKOscillator()
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
        input.start()
        AKTestMD5("699a91ae893b3899a2f4711f7edca067")
    }

}
