//
//  autoWahTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AutoWahTests: AKTestCase {

    func testAmplitude() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah(wah: 0.5, amplitude: 0.5)
        }
        AKTestMD5("2cfb433f51a0147fa682850717912761")
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah()
        }
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }

    func testWah() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah(wah: 0.5)
        }
        AKTestMD5("876bd47ac6551422b0becc5b227508de")
    }

}
