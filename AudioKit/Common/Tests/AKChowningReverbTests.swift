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
        AKTestMD5("970a995fcbd64d23b7c2e539603850f6")
    }
}
