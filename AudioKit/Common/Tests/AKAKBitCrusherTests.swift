//
//  AKBitCrusherTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKBitCrusherTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBitCrusher(input)
        input.start()
        AKTestMD5("7887dd8d95b9116bc123a09fc15e040f")
    }
}
