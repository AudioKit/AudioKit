//
//  AKPeakingParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKPeakingParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("c70baaa31a6917c731b2b9b274a015b5")
    }
}
