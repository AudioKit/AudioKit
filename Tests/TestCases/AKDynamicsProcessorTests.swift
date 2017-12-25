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
        AKTestMD5("0a3ded76baa047969bb90eae8fc1f7a9")
    }

}
