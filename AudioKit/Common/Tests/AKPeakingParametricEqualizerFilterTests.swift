//
//  AKPeakingParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPeakingParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("d1003d6785e625834b6c9772a32017ee")
    }
}
