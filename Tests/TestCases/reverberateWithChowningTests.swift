//
//  reverberateWithChowningTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class ReverberateWithChowningTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.reverberateWithChowning()
        }
        AKTestMD5("fe853b4997494453851448cf5e9287dd")
    }

}
