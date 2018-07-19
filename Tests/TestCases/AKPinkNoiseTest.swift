//
//  AKPinkNoiseTest.swift
//  AudioKitTestSuite
//
//  Created by Nicholas Arner, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPinkNoiseTests: AKTestCase {

    func testDefault() {
        output = AKPinkNoise()
        AKTestMD5("b56ddd343583e6e58b559d10b8b4c147")
    }

    func testAmplitude() {
        output = AKPinkNoise(amplitude: 0.5)
        AKTestMD5("a30e01dd9169d41be4d0ae5c5896e0bd")
    }
}
