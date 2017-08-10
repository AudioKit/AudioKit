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
        output = AKDynamicsProcessor(input)
        AKTestMD5("7394f7fa840b20c1cd0f50eebec28b2e")
    }
}
