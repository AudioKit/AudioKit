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

    func testDefault() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input)
        input.start()
        AKTestMD5("793ce26c8e18b1e224460cf3a7b45931")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input, attackDuration: 0.05) // Only attack is being tested properly
        input.start()
        AKTestMD5("f42e67b02ea316f01db2a145321ce450")
    }
}
