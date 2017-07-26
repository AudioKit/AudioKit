//
//  clipTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class ClipTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.clip()
        }
        AKTestMD5("40cdab8a77a2d476ef81f76a7e79ce10")
    }

    func testClip() {
        output = AKOperationEffect(input) { input, _ in
            return input.clip(0.5)
        }
        AKTestMD5("2bd033385d2ea8a6f0b6ddd2dd775eb9")
    }

}
