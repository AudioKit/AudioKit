//
//  sawtoothWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class sawtoothWaveTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.sawtoothWave()
        }
        AKTestMD5("1876f099ad6aa4f04c8d2b52ced9a87a")
    }

}
