//
//  triangleWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class triangleWaveTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.triangleWave()
        }
        AKTestMD5("33cdb96f34af9d731d3ec064e26c8043")
    }

}
