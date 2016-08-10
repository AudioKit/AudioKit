//
//  AKDynamicsProcessorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKDynamicsProcessorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDynamicsProcessor(input)
        input.start()
        AKTestMD5("6363369a3ca55355314be8e8decdc00d")
    }
}
