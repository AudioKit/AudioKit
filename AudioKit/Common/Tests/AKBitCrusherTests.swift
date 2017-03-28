//
//  AKBitCrusherTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKBitCrusherTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBitCrusher(input)
        input.start()
        AKTestMD5("801dc339290c62b79f18ae22828ee665")
    }
}
