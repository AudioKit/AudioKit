//
//  AKBoosterTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 11/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBoosterTests: AKTestCase {
    
    func testDefault() {
        output = AKBooster(input)
        AKTestNoEffect()
    }

//    func testDefault2() {
//        output = AKBooster2(input)
//        AKTestNoEffect()
//    }

    func testParameters() {
        output = AKBooster(input, gain: 2.0)
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }

    func testParameters2() {
        output = AKBooster(input, gain: 0.5)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }

//    func testParameters3() {
//        output = AKBooster2(input, gain: 2.0)
//        AKTestMD5("845f682ff41d7017cd37942f3ccb21c2")
//    }
//
//    func testParameters4() {
//        output = AKBooster2(input, gain: 0.5)
//        AKTestMD5("5b0bf534309552ac6bc55ae7e831f7cc")
//    }

}
