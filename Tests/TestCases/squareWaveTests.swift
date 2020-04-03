//
//  squareWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class SquareWaveTests: AKTestCase {

    let square = AKOperationGenerator { _ in return AKOperation.squareWave() }

    override func setUp() {
        afterStart = { self.square.start() }
        duration = 1.0
    }

    func testDefault() {
        output = square
        AKTestMD5("8c93ddbc4ce8393a53d2a2c68ab45dca")
    }

}
