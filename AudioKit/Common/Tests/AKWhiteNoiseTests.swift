//
//  AKWhiteNoiseTests.swift
//  AudioKitTestSuite
//
//  Created by Nicholas Arner on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKWhiteNoiseTests: AKTestCase {

    func testDefault() {
        output = AKWhiteNoise()
        AKTestMD5("d6b3484278d57bc40ce66df5decb88be")
    }
}
