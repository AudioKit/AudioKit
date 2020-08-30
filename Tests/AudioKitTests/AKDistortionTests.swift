// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDistortionTests: AKTestCase2 {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testCubicTerm() {
        output = AKDistortion(input, cubicTerm: 0.65)
        AKTest()
    }

    func testDecay() {
        output = AKDistortion(input, decay: 2)
        AKTest()
    }

    func testDecimation() {
        output = AKDistortion(input, decimation: 0.61)
        AKTest()
    }

    func testDecimationMix() {
        output = AKDistortion(input, decimationMix: 0.62)
        AKTest()
    }

    func testDefault() {
        output = AKDistortion(input)
        AKTest()
    }

    func testDelay() {
        output = AKDistortion(input, delay: 0.2)
        AKTest()
    }

    func testDelayMix() {
        output = AKDistortion(input, delayMix: 0.6)
        AKTest()
    }

    func testFinalMix() {
        output = AKDistortion(input, finalMix: 0.69)
        AKTest()
    }

    func testLinearTerm() {
        output = AKDistortion(input, linearTerm: 0.63)
        AKTest()
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
        AKTest()
    }

    func testPolynomialMix() {
        output = AKDistortion(input, polynomialMix: 0.66)
        AKTest()
    }

    func testRingModBalance() {
        output = AKDistortion(input, ringModBalance: 0.67, ringModMix: 0.68)
        AKTest()
    }

    func testRingModFreq1() {
        output = AKDistortion(input, ringModFreq1: 200, ringModMix: 0.68)
        AKTest()
    }

    func testRingModFreq2() {
        output = AKDistortion(input, ringModFreq2: 300, ringModMix: 0.68)
        AKTest()
    }

    func testRingModMix() {
        output = AKDistortion(input, ringModMix: 0.68)
        AKTest()
    }

    func testRounding() {
        output = AKDistortion(input, rounding: 0.5)
        AKTest()
    }

    func testSquaredTerm() {
        output = AKDistortion(input, squaredTerm: 0.64)
        AKTest()
    }

    func testSoftClipGain() {
        output = AKDistortion(input, softClipGain: 0)
        AKTest()
    }

}
