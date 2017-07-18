//
//  AKFlatFrequencyResponseReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKFlatFrequencyResponseReverb(input)
        input.start()
        AKTestMD5("628cf85086dfdbab1c4e98550b5e716c")
    }

    func testReverbDuration() {
        let input = AKOscillator()
        output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1)
        input.start()
        AKTestMD5("df8f2efe60adaac9f29d73d1fab2223c")
    }
}
