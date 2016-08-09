//
//  AKFormantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKFormantFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKFormantFilter(input)
        input.start()
        AKTestMD5("d72788f70f5034a6300f32eae5cba575")
    }
}
