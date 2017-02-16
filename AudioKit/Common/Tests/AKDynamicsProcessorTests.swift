//
//  AKDynamicsProcessorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDynamicsProcessorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDynamicsProcessor(input)
        input.start()
        AKTestMD5("7394f7fa840b20c1cd0f50eebec28b2e")
    }
}
