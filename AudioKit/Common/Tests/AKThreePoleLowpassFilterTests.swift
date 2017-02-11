//
//  AKThreePoleLowpassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKThreePoleLowpassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKThreePoleLowpassFilter(input)
        input.start()
        AKTestMD5("8c459009f9b7a720bd2b7207ae41749f")
    }
}
