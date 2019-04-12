//
//  AKTanhDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKTanhDistortionTests: AKTestCase {

    func testDefault() {
        output = AKTanhDistortion(input)
        AKTestMD5("bc4b99a57e2695ec9c8fbdebda8b0aa4")
    }

    func testNegativeShapeParameter() {
        output = AKTanhDistortion(input, negativeShapeParameter: 1)
        AKTestMD5("4810b5dbcfbb99de192ba9c57531df61")
    }

    func testParameters() {
        output = AKTanhDistortion(input, pregain: 4, postgain: 1, positiveShapeParameter: 1, negativeShapeParameter: 1)
        AKTestMD5("42171b8371cf4b3a616967da9bc23190")
    }

    func testPositiveShapeParameter() {
        output = AKTanhDistortion(input, positiveShapeParameter: 1)
        AKTestMD5("440ea7836049aaa8385a6289c13f52a9")
    }

    func testPostgain() {
        output = AKTanhDistortion(input, postgain: 1)
        AKTestMD5("a2cbfbdcd13238055f6f92be02d72f47")
    }

    func testPregain() {
        output = AKTanhDistortion(input, pregain: 4)
        AKTestMD5("762356ed0c71f8091fb9bb4d051b1013")
    }

}
