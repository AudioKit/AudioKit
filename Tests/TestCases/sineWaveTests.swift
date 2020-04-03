//
//  sineWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class SineWaveTests: AKTestCase {

    let sine = AKOperationGenerator { _ in return AKOperation.sineWave() }

    override func setUp() {
        afterStart = { self.sine.start() }
        duration = 1.0
    }

    func testDefault() {
        output = sine
        AKTestMD5("02e8662be33038033cb0d01763792a11")
    }

}
