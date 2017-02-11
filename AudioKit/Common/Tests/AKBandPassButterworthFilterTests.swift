//
//  AKBandPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKBandPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBandPassButterworthFilter(input)
        input.start()
        AKTestMD5("574b9097eff0c33a2a04ae112fe19164")
    }
}
