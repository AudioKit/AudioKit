//
//  AKShakerTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 8/12/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKShakerTests: AKTestCase {

    func testShaker() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .maraca)
        output = shaker

        // auditionTest()
        AKTestMD5("6ab4af41b487ea9faacf0f09a99bd304")
    }

    func testShakerType() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .tunedBambooChimes)
        output = shaker

        // auditionTest()
        AKTestMD5("edafbc5ec1e2b17f6fa90246d2660969")
    }

    func testShakerAmplitude() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .tunedBambooChimes, amplitude: 1.0)
        output = shaker

        // auditionTest()
        AKTestMD5("ec88895331e9554ffd18d9484580cc44")
    }

}
