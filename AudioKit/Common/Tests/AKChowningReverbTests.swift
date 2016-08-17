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
        AKTestMD5("1189b85f351b279ff2988e249686a26b")
    }
}
