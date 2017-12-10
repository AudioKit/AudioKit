//
//  AKWhiteNoiseTests.swift
//  AudioKitTestSuite
//
//  Created by Nicholas Arner on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKWhiteNoiseTests: AKTestCase {

    func testDefault() {
        output = AKWhiteNoise()
        AKTestMD5("d6b3484278d57bc40ce66df5decb88be")
    }

    func testAmplitude() {
        output = AKWhiteNoise(amplitude: 0.5)
        AKTestMD5("18d62e4331862babc090ea8168c78d41")
    }
}
