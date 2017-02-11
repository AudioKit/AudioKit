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
}
