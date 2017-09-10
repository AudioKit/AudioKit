//
//  morphingOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class MorphingOscillatorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.morphingOscillator()
        }
        AKTestMD5("8afb1f2f28dd56487cdf1011b820148d")
    }

}
