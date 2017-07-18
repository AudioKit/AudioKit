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
        let input = AKOscillator()
        output = AKDistortion(input)
        input.start()
        AKTestMD5("aeeab86be7d9e6842022077dbd69eaeb")
    }

    func testParameters() {
        let input = AKOscillator()
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
        input.start()
        AKTestMD5("a1732b3b9d4d1915e31bda4e5406ffdb")
    }


    func testDelay() {
        let input = AKOscillator()
        output = AKDistortion(input, delay: 0.2)
        input.start()
        AKTestMD5("c85cfde3be324f1a9e51843d9bb2e3c8")
    }

    func testDecay() {
        let input = AKOscillator()
        output = AKDistortion(input, decay: 2)
        input.start()
        AKTestMD5("49c65627275f8151b0329a9d25cb40d7")
    }

    func testDelayMix() {
        let input = AKOscillator()
        output = AKDistortion(input, delayMix: 0.6)
        input.start()
        AKTestMD5("128b5fb7e5f338ff58ab2f6e745b69b0")
    }

    func testDecimation() {
        let input = AKOscillator()
        output = AKDistortion(input, decimation: 0.61)
        input.start()
        AKTestMD5("3514a930988aa22017e26bd887564b6e")
    }

    func testRounding() {
        let input = AKOscillator()
        output = AKDistortion(input, rounding: 0.5)
        input.start()
        AKTestMD5("3c07ee738c3e74d3e54a685a06d7211e")
    }

    func testDecimationMix() {
        let input = AKOscillator()
        output = AKDistortion(input, decimationMix: 0.62)
        input.start()
        AKTestMD5("bb8587148e44ef93c5e4e5b970b01804")
    }

    func testLinearTerm() {
        let input = AKOscillator()
        output = AKDistortion(input, linearTerm: 0.63)
        input.start()
        AKTestMD5("44bf5e611dbd6bd6f8dae99d00809f60")
    }

    func testSquaredTerm() {
        let input = AKOscillator()
        output = AKDistortion(input, squaredTerm: 0.64)
        input.start()
        AKTestMD5("22eb8b73e432980c0c1fe118376e52d5")
    }

    func testCubicTerm() {
        let input = AKOscillator()
        output = AKDistortion(input, cubicTerm: 0.65)
        input.start()
        AKTestMD5("2fa76a60720720f80307b756e805df67")
    }

    func testPolynomialMix() {
        let input = AKOscillator()
        output = AKDistortion(input, polynomialMix: 0.66)
        input.start()
        AKTestMD5("3b3034a7cedc197f1315d6c7f9ac2a00")
    }

    func testRingModFreq1() {
        let input = AKOscillator()
        output = AKDistortion(input, ringModFreq1: 200, ringModMix: 0.68)
        input.start()
        AKTestMD5("2a6a452e1f62dcdc2b44e4b16d4d2ade")
    }

    func testRingModFreq2() {
        let input = AKOscillator()
        output = AKDistortion(input, ringModFreq2: 300, ringModMix: 0.68)
        input.start()
        AKTestMD5("7ce971de5379b981eba583787ddbaf4e")
    }

    func testRingModBalance() {
        let input = AKOscillator()
        output = AKDistortion(input, ringModBalance: 0.67, ringModMix: 0.68)
        input.start()
        AKTestMD5("c95dd770b18c5c4c32f23c37e2b655f9")
    }

    func testRingModMix() {
        let input = AKOscillator()
        output = AKDistortion(input, ringModMix: 0.68)
        input.start()
        AKTestMD5("f20e32e87bb605e078bb88c76b9390e6")
    }

    func testSoftClipGain() {
        let input = AKOscillator()
        output = AKDistortion(input, softClipGain: 0)
        input.start()
        AKTestMD5("930f147644f4631e130e4b821f63a2eb")
    }

    func testFinalMix() {
        let input = AKOscillator()
        output = AKDistortion(input, finalMix: 0.69)
        input.start()
        AKTestMD5("59dfef346d41615f1eed51bf8016ba73")
    }
}
