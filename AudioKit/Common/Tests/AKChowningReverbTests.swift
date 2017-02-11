//
//  AKChowningReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKChowningReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKChowningReverb(input)
        input.start()
        AKTestMD5("038cb0338d1615e9a5d7c2750f24e6da")
    }
}
