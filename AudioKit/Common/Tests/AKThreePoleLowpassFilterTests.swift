//
//  AKThreePoleLowpassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKThreePoleLowpassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKThreePoleLowpassFilter(input)
        input.start()
        AKTestMD5("8c459009f9b7a720bd2b7207ae41749f")
    }
}
