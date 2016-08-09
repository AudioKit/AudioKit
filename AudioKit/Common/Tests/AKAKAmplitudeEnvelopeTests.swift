//
//  AKAmplitudeEnvelopeTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKAmplitudeEnvelopeTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input)
        input.start()
        AKTestMD5("")
    }
}
