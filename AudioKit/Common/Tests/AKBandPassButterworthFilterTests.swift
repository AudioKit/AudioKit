//
//  AKBandPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKBandPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBandPassButterworthFilter(input)
        input.start()
        AKTestMD5("92b75d7051cc8fdcde9c2f5a3d26d7b2")
    }
}
