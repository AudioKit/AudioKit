//
//  AKParametricEQTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKParametricEQTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKParametricEQ(input)
        input.start()
        AKTestMD5("ac7682b189b19dd65ada2be93fe9e041")
    }
}
