//
//  AKDynamicsProcessorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKDynamicsProcessorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDynamicsProcessor(input)
        input.start()
        AKTestMD5("5b720d99c298fcecd93a0a982e3cf8e1")
    }
}
