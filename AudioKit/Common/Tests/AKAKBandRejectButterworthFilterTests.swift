//
//  AKBandRejectButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKBandRejectButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBandRejectButterworthFilter(input)
        input.start()
        AKTestMD5("d1fae8a7406110b5250d9861b76a52fa")
    }
}
