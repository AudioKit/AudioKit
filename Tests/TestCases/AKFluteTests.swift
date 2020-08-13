//
//  AKFluteTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 8/12/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFluteTests: AKTestCase {

    func testFlute() {

        akSetSeed(0)

        let flute = AKFlute()
        flute.trigger(frequency: 440)
        output = flute

        // auditionTest()
        AKTestMD5("f7fd94da1321d1727af4d12d6355437c")

    }

}
