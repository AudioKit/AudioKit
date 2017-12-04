//
//  AKAmplitudeEnvelopeTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKAmplitudeEnvelopeTests: AKTestCase {
    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
    }

    func testAttack() {
        output = AKAmplitudeEnvelope(input, attackDuration: 0.123_4)
        AKTestMD5("73731f4bd688af999e29938ff02e9c0d")
    }

    func testDecay() {
        output = AKAmplitudeEnvelope(input, decayDuration: 0.234, sustainLevel: 0.345)
        AKTestMD5("7ae70f11c78ea07a57d29fc93a42b53d")
    }

    func testDefault() {
        output = AKAmplitudeEnvelope(input)
        AKTestMD5("ed96eabba9ccc7b2ebc3c7d48f7f3abc")
    }

    func testParameters() {
        output = AKAmplitudeEnvelope(input, attackDuration: 0.123_4, decayDuration: 0.234, sustainLevel: 0.345)
        AKTestMD5("c25e1343ea146ceff27ce83885e4b61a")
    }

    func testSustain() {
        output = AKAmplitudeEnvelope(input, sustainLevel: 0.345)
        AKTestMD5("74ce58757e70947544ed8353e2477e63")
    }

    // Release is not tested at this time since there is no sample accurate way to define release point

}
