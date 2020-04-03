//
//  morphingOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class MorphingOscillatorTests: AKTestCase {

    var oscillator = AKOperationGenerator { _ in return AKOperation.morphingOscillator() }

    override func setUp() {
        afterStart = { self.oscillator.start() }
        duration = 1.0
    }

    func testDefault() {
        output = oscillator
        AKTestMD5("d45f894aa1d536e63bffc536dc7f4edf")
    }

}
