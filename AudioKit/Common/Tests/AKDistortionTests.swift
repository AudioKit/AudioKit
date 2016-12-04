//
//  AKDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKDistortionTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDistortion(input)
        input.start()
        AKTestMD5("916365c697093a0bb8b5b75b73463887")
    }
}
