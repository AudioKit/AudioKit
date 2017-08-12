//
//  AKDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDistortionTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testCubicTerm() {
        output = AKDistortion(input, cubicTerm: 0.65)
        AKTestMD5("9dca12baacae3c7190d358fd9682d483")
    }

    func testDecay() {
        output = AKDistortion(input, decay: 2)
        AKTestMD5("cb80e1702ec954880f78da716533df33")
    }

    func testDecimation() {
        output = AKDistortion(input, decimation: 0.61)
        AKTestMD5("19633943272798663095159a27c4d06a")
    }

    func testDecimationMix() {
        output = AKDistortion(input, decimationMix: 0.62)
        AKTestMD5("b176942f8f27bfc782b9989bbabc49c6")
    }

    func testDefault() {
        output = AKDistortion(input)
        AKTestMD5("809d9eb95a91e34dc2ebb957dd525394")
    }

    func testDelay() {
        output = AKDistortion(input, delay: 0.2)
        AKTestMD5("6de6a44ef0b8b3a072c0355b56c69e83")
    }

    func testDelayMix() {
        output = AKDistortion(input, delayMix: 0.6)
        AKTestMD5("1a499e4fe4b036950c85f48832cf0b75")
    }

    func testFinalMix() {
        output = AKDistortion(input, finalMix: 0.69)
        AKTestMD5("5040767304222a74ff0a5f61ee890ab3")
    }

    func testLinearTerm() {
        output = AKDistortion(input, linearTerm: 0.63)
        AKTestMD5("a60c35c5f4552b50a83889534852d490")
    }

    func testParameters() {
        output = AKDistortion(input,
                              delay: 0.2,
                              decay: 2,
                              delayMix: 0.6,
                              decimation: 0.61,
                              rounding: 0.5,
                              decimationMix: 0.62,
                              linearTerm: 0.63,
                              squaredTerm: 0.64,
                              cubicTerm: 0.65,
                              polynomialMix: 0.66,
                              ringModFreq1: 200,
                              ringModFreq2: 300,
                              ringModBalance: 0.67,
                              ringModMix: 0.68,
                              softClipGain: 0,
                              finalMix: 0.69)
        AKTestMD5("b20419cbe57b8ff46b7082ccec6fb9f5")
    }

    func testPolynomialMix() {
        output = AKDistortion(input, polynomialMix: 0.66)
        AKTestMD5("844168c2749002acf535a0599952005a")
    }

    func testRingModBalance() {
        output = AKDistortion(input, ringModBalance: 0.67, ringModMix: 0.68)
        AKTestMD5("9cad389fcaae58d25874838325888c7b")
    }

    func testRingModFreq1() {
        output = AKDistortion(input, ringModFreq1: 200, ringModMix: 0.68)
        AKTestMD5("219ad6174a9c5fe683220276f139496c")
    }

    func testRingModFreq2() {
        output = AKDistortion(input, ringModFreq2: 300, ringModMix: 0.68)
        AKTestMD5("2974848b83e6d6c453443b89b8232b56")
    }

    func testRingModMix() {
        output = AKDistortion(input, ringModMix: 0.68)
        AKTestMD5("0a083989773cc93c6f2d8940df181acd")
    }

    func testRounding() {
        output = AKDistortion(input, rounding: 0.5)
        AKTestMD5("0960d44f15db32056aa6e8146025d20a")
    }

    func testSquaredTerm() {
        output = AKDistortion(input, squaredTerm: 0.64)
        AKTestMD5("1bf56e3620ec5790483c16fded69c06f")
    }

    func testSoftClipGain() {
        output = AKDistortion(input, softClipGain: 0)
        AKTestMD5("eeaa785a6d4087a7abb9f0145f9a7540")
    }

}
