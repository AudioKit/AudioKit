//
//  AKToneFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKToneFilter(input)
        input.start()
        AKTestMD5("71f8df21291940cef3ae5ba58b62d08c")
    }
}
