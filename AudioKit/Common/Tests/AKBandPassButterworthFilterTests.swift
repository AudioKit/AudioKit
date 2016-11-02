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
        AKTestMD5("587b6cf54a381bf723d4879a00868912")
    }
}
