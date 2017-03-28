//
//  AKTanhDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKTanhDistortionTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKTanhDistortion(input)
        input.start()
        AKTestMD5("715fba92aa618f5dd4c15825a32aee91")
    }
}
