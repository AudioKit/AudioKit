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

    func testDefault() {
        let input = AKOscillator()
        output = AKZitaReverb(input)
        input.start()
        AKTestMD5("a900f6e090645c9cdc89c466fdb42672")
    }

    func testParametersSetOnInit() {
        let input = AKOscillator()
        output = AKZitaReverb(input,
                              delay: 0.1,
                              crossoverFrequency: 200.666,
                              lowReleaseTime: 1.5666,
                              midReleaseTime: 1.0666,
                              dampingFrequency: 3000.666,
                              equalizerFrequency1: 300,
                              equalizerLevel1: 1,
                              equalizerFrequency2: 1400,
                              equalizerLevel2: -1,
                              dryWetMix: 0.5)

        input.start()
        AKTestMD5("a9f84d322eb8990cdaf18a1d38a711a4")
    }

    func testParametersSetAfterInit() {
        let input = AKOscillator()
        let effect = AKZitaReverb(input)
        effect.delay = 0.1
        effect.crossoverFrequency = 200.666
        effect.lowReleaseTime = 1.5666
        effect.midReleaseTime = 1.0666
        effect.dampingFrequency = 3000.666
        effect.equalizerFrequency1 = 300
        effect.equalizerLevel1 = 1
        effect.equalizerFrequency2 = 1400
        effect.equalizerLevel2 = -1
        effect.dryWetMix = 0.5
        print("Aure")
        print(effect.lowReleaseTime)
        print(effect.midReleaseTime)
        output = effect
        input.start()
        AKTestMD5("a9f84d322eb8990cdaf18a1d38a711a4")
    }

}
