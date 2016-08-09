//
//  AKCombFilterReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKCombFilterReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKCombFilterReverb(input)
        input.start()
        AKTestMD5("882c7029a5097769b85bd176f5752684")
    }
}
