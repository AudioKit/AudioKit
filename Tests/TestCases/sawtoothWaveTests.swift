//
//  sawtoothWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class SawtoothWaveTests: AKTestCase {

    let sawtooth = AKOperationGenerator { _ in return AKOperation.sawtoothWave() }

    override func setUp() {
        afterStart = { self.sawtooth.start() }
        duration = 1.0
    }

    func testDefault() {
        output = sawtooth
        AKTestMD5("1876f099ad6aa4f04c8d2b52ced9a87a")
    }

}
