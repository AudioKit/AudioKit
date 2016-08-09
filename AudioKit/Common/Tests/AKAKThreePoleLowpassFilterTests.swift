//
//  AKThreePoleLowpassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKThreePoleLowpassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKThreePoleLowpassFilter(input)
        input.start()
        AKTestMD5("36e51c68a237e6ae6786ca753166ce12")
    }
}
