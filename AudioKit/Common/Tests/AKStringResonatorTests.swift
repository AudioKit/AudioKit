//
//  AKStringResonatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKStringResonatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKStringResonator(input)
        input.start()
        AKTestMD5("2498002dd1bead4c55715d76e2017022")
    }
}
