//
//  AKFlatFrequencyResponseReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKFlatFrequencyResponseReverb(input)
        input.start()
        AKTestMD5("628cf85086dfdbab1c4e98550b5e716c")
    }
}
