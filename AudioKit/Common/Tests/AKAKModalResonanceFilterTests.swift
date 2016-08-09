//
//  AKModalResonanceFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKModalResonanceFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKModalResonanceFilter(input)
        input.start()
        AKTestMD5("ac0670faf0f2884683269f80f35cda71")
    }
}
