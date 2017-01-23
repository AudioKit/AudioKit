//
//  AKAmplitudeEnvelopeTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKAmplitudeEnvelopeTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input)
        input.start()
        AKTestMD5("793ce26c8e18b1e224460cf3a7b45931")
    }
}
