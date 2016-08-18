//
//  AKTanhDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKTanhDistortionTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKTanhDistortion(input)
        input.start()
        AKTestMD5("467a3c8d268b922388029d0c9a80debb")
    }
}
