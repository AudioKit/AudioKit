//
//  pluckedStringTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class PluckedStringTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.pluckedString(trigger: AKOperation.metronome())
        }
        AKTestMD5("ef5660234d2603a3f945cde22a967102")
    }

}
