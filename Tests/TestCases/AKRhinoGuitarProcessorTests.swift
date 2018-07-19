//
//  AKRhinoGuitarProcessorTests.swift
//  iOSTestSuiteTests
//
//  Created by Aurelius Prochazka on 3/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKRhinoGuitarProcessorTests: AKTestCase {

    func testDefault() {
        output = AKRhinoGuitarProcessor(input)
        AKTestMD5("b7a79af92c91dec9a8ea705f449e6a4a")
    }

    func testDistortion() {
        output = AKRhinoGuitarProcessor(input, distortion: 3)
        AKTestMD5("47e5fd119e13e0661d190f00b981b594")
    }

    func testHighGain() {
        output = AKRhinoGuitarProcessor(input, highGain: 0.55)
        AKTestMD5("d89eca3f6c8fc3f298c8eb583eb5ee0a")
    }

    func testLowGain() {
        output = AKRhinoGuitarProcessor(input, lowGain: 0.66)
        AKTestMD5("fb296724945d97eb066132760f398855")
    }

    func testMidGain() {
        output = AKRhinoGuitarProcessor(input, midGain: 0.44)
        AKTestMD5("4546b5e4081ab44908c5e2c639dfd48c")
    }

    func testPostGain() {
        output = AKRhinoGuitarProcessor(input, postGain: 2.2)
        AKTestMD5("c3bef3fa0978b5d55d6577e3683880f7")
    }

    func testPreGain() {
        output = AKRhinoGuitarProcessor(input, preGain: 2.2)
        AKTestMD5("4bdfa2afc5f63ed79ad5f19ed0a69ced")
    }

}
