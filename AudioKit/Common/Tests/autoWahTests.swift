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

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah()
        }
        AKTestMD5("59fbba3cba865cad6724234e76dc8fe7")
    }

    func testWah() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah(wah: 0.5)
        }
        AKTestMD5("8f2c5dcb94caf856f9e75f81d0174cdf")
    }

    func testAmplitude() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah(wah: 0.5, amplitude: 0.5)
        }
        AKTestMD5("557d83fe62c2a80e161ed981b92c9105")
    }

}
