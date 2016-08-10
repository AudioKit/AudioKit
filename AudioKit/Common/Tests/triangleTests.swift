//
//  triangleTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class triangleTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.triangle()
        }
        AKTestMD5("2f0d3ee205fe2ef312df7bd31e4a2e32")
    }

}
