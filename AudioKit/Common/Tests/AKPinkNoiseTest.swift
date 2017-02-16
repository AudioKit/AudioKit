//
//  AKPinkNoiseTest.swift
//  AudioKitTestSuite
//
//  Created by Nicholas Arner on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPinkNoiseTests: AKTestCase {

    func testDefault() {
        output = AKPinkNoise()
        AKTestMD5("b56ddd343583e6e58b559d10b8b4c147")
    }
}
