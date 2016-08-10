//
//  pluckedStringTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class pluckedStringTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.pluckedString(trigger: AKOperation.metronome())
        }
        AKTestMD5("ef5660234d2603a3f945cde22a967102")
    }

}
