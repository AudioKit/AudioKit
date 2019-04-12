//
//  AKFlatFrequencyResponseReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        output = AKFlatFrequencyResponseReverb(input)
        AKTestMD5("76324e03c74ad5654af5241f82acdadd")
    }

    func testReverbDuration() {
        output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1)
        AKTestMD5("e53b197b557f751a35fbcf799c2bb70b")
    }
}
