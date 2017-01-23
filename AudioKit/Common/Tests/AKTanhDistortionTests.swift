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
        AKTestMD5("715fba92aa618f5dd4c15825a32aee91")
    }
}
