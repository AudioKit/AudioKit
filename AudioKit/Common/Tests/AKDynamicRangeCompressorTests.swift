//
//  AKDynamicRangeCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 7/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKDynamicRangeCompressorTests: AKTestCase {
    
    func testDefault() {
        let input = AKOscillator()
        output = AKDynamicRangeCompressor(input)
        input.start()
        AKTestMD5("30e9a7639b3af4f8159e307bf48a2844")
    }

    func testParametersSetOnInit() {
        let input = AKOscillator()
        output = AKDynamicRangeCompressor(input, ratio: 0.5, threshold: 1, attackTime: 0.2, releaseTime: 0.2)

        AKTestMD5("882c7029a5097769b85bd176f5752684")
    }
    
}
