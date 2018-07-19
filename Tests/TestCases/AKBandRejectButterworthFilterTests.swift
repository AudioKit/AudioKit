//
//  AKBandRejectButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBandRejectButterworthFilterTests: AKTestCase {

    func testBandwidth() {
        output = AKBandRejectButterworthFilter(input, bandwidth: 200)
        AKTestMD5("3533f7d0fbd1ff21a670d1e52757780b")
    }

    func testCenterFrequency() {
        output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500)
        AKTestMD5("50cea6efe3c99c9bd21421f4e756c2d8")
    }

    func testDefault() {
        output = AKBandRejectButterworthFilter(input)
        AKTestMD5("ce86ca4104181a5ddbe7ad5c7c4f75ae")
    }

    func testParameters() {
        output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTestMD5("fb657149a33fdea35a12ab46c8c5c37f")
    }

}
