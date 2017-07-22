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

    func testDefault() {
        output = AKDistortion(input)
        AKTestMD5("aeeab86be7d9e6842022077dbd69eaeb")
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
        AKTestMD5("a1732b3b9d4d1915e31bda4e5406ffdb")
    }


    func testDelay() {
        output = AKDistortion(input, delay: 0.2)
        AKTestMD5("c85cfde3be324f1a9e51843d9bb2e3c8")
    }

    func testDecay() {
        output = AKDistortion(input, decay: 2)
        AKTestMD5("49c65627275f8151b0329a9d25cb40d7")
    }

    func testDelayMix() {
        output = AKDistortion(input, delayMix: 0.6)
        AKTestMD5("128b5fb7e5f338ff58ab2f6e745b69b0")
    }

    func testDecimation() {
        output = AKDistortion(input, decimation: 0.61)
        AKTestMD5("3514a930988aa22017e26bd887564b6e")
    }

    func testRounding() {
        output = AKDistortion(input, rounding: 0.5)
        AKTestMD5("3c07ee738c3e74d3e54a685a06d7211e")
    }

    func testDecimationMix() {
        output = AKDistortion(input, decimationMix: 0.62)
        AKTestMD5("bb8587148e44ef93c5e4e5b970b01804")
    }

    func testLinearTerm() {
        output = AKDistortion(input, linearTerm: 0.63)
        AKTestMD5("44bf5e611dbd6bd6f8dae99d00809f60")
    }

    func testSquaredTerm() {
        output = AKDistortion(input, squaredTerm: 0.64)
        AKTestMD5("22eb8b73e432980c0c1fe118376e52d5")
    }

    func testCubicTerm() {
        output = AKDistortion(input, cubicTerm: 0.65)
        AKTestMD5("2fa76a60720720f80307b756e805df67")
    }

    func testPolynomialMix() {
        output = AKDistortion(input, polynomialMix: 0.66)
        AKTestMD5("3b3034a7cedc197f1315d6c7f9ac2a00")
    }

    func testRingModFreq1() {
        output = AKDistortion(input, ringModFreq1: 200, ringModMix: 0.68)
        AKTestMD5("2a6a452e1f62dcdc2b44e4b16d4d2ade")
    }

    func testRingModFreq2() {
        output = AKDistortion(input, ringModFreq2: 300, ringModMix: 0.68)
        AKTestMD5("7ce971de5379b981eba583787ddbaf4e")
    }

    func testRingModBalance() {
        output = AKDistortion(input, ringModBalance: 0.67, ringModMix: 0.68)
        AKTestMD5("c95dd770b18c5c4c32f23c37e2b655f9")
    }

    func testRingModMix() {
        output = AKDistortion(input, ringModMix: 0.68)
        AKTestMD5("f20e32e87bb605e078bb88c76b9390e6")
    }

    func testSoftClipGain() {
        output = AKDistortion(input, softClipGain: 0)
        AKTestMD5("930f147644f4631e130e4b821f63a2eb")
    }

    func testFinalMix() {
        output = AKDistortion(input, finalMix: 0.69)
        AKTestMD5("59dfef346d41615f1eed51bf8016ba73")
    }
}
