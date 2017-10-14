//
//  AKDecimatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDecimatorTests: AKTestCase {

    func testDecimation() {
        output = AKDecimator(input, decimation: 0.75)
        AKTestMD5("a7f1536d43cc645f531de000197263e0")
    }

    func testDefault() {
        output = AKDecimator(input)
        AKTestMD5("313610eb609ce58855424ad3bdb221e5")
    }

    func testMix() {
        output = AKDecimator(input, mix: 0.5)
        AKTestMD5("9580c7f80056bbbd517b16dd045f6677")
    }

    func testParameters() {
        output = AKDecimator(input, decimation: 0.75, rounding: 0.5, mix: 0.5)
        AKTestMD5("23410862de9bc64b854d3a30441adfe5")
    }

    func testRounding() {
        output = AKDecimator(input, rounding: 0.5)
        AKTestMD5("7f3c4b7ab3e039f2d81ac7fff5642d9a")
    }

}
