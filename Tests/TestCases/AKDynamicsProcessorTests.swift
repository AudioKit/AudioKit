//
//  AKDynamicsProcessorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKDynamicsProcessorTests: AKTestCase {

    func testDefault() {
        output = AKDynamicsProcessor(input)
        AKTestMD5("0a3ded76baa047969bb90eae8fc1f7a9")
    }

}
