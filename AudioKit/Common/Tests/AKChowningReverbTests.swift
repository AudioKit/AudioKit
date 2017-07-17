//
//  AKChowningReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKChowningReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKChowningReverb(input)
        input.start()
        AKTestMD5("038cb0338d1615e9a5d7c2750f24e6da")
    }

    func testDifferentInput() {
        let input = AKOscillator(waveform: AKTable(.square))
        output = AKChowningReverb(input)
        input.start()
        AKTestMD5("438cd66fa252a46d9fd26bd5ed50c8d9")
    }

}
