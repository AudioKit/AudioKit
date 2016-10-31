//
//  AKHighPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKHighPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighPassButterworthFilter(input)
        input.start()
        AKTestMD5("6b64e7b172b12b9722a6374ac9fe9663")
    }
}
