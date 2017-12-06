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
        AKTestMD5("d45f894aa1d536e63bffc536dc7f4edf")
    }

}
