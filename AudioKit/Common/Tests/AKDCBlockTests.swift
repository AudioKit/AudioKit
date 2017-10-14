//
//  AKDCBlockTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDCBlockTests: AKTestCase {

    func testActuallyProcessing() {
        let input = AKOscillator(waveform: AKTable(.square))
        output = input
        AKTestMD5Not("cdca0c19d803bbf2cce357df5fca3013")
    }

    func testDefault() {
        output = AKDCBlock(input)
        AKTestMD5("cdca0c19d803bbf2cce357df5fca3013")
    }

}
