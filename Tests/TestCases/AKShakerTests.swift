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

        akShakerSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger()
        output = shaker

        // auditionTest()
        AKTestMD5("233971b259b64ee9e151ddc0c96224fb")
    }

    func testShakerType() {

        akShakerSetSeed(0)

        let shaker = AKShaker()
        shaker.type = .tunedBambooChimes
        shaker.trigger()
        output = shaker

        // auditionTest()
        AKTestMD5("f122cdfc08bd68bbf5e5d0aa10a74565")
    }

    func testShakerAmplitude() {

        akShakerSetSeed(0)

        let shaker = AKShaker()
        shaker.type = .tunedBambooChimes
        shaker.amplitude = 0.5
        shaker.trigger()
        output = shaker

        // auditionTest()
        AKTestMD5("f122cdfc08bd68bbf5e5d0aa10a74565")
    }

}
