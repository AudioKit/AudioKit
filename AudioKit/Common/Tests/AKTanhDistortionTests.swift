//
//  AKTanhDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKTanhDistortionTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKTanhDistortion(input)
        input.start()
        AKTestMD5("715fba92aa618f5dd4c15825a32aee91")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKTanhDistortion(input, pregain: 4, postgain: 1, postiveShapeParameter: 1, negativeShapeParameter: 1)
        input.start()
        AKTestMD5("58454e9d64cbf880ef7bb56a1130ffff")
    }

    func testPregain() {
        let input = AKOscillator()
        output = AKTanhDistortion(input, pregain: 4)
        input.start()
        AKTestMD5("40e4a6f674893e21a5a8a71b1977b6ff")
    }

    func testPostgain() {
        let input = AKOscillator()
        output = AKTanhDistortion(input, postgain: 1)
        input.start()
        AKTestMD5("d338041a58f421b6d61ff9b108fed526")
    }

    func testPostiveShapeParameter() {
        let input = AKOscillator()
        output = AKTanhDistortion(input, postiveShapeParameter: 1)
        input.start()
        AKTestMD5("22c94a95754c623cf732f7af21e4faff")
    }

    func testNegativeShapeParameter() {
        let input = AKOscillator()
        output = AKTanhDistortion(input, negativeShapeParameter: 1)
        input.start()
        AKTestMD5("1a5dec99e73405ee94140bea11d8e74a")
    }
}
