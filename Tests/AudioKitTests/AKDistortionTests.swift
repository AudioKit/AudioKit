// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDistortionTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testCubicTerm() {
        engine.output = AKDistortion(input, cubicTerm: 0.65)
        AKTest()
    }

    func testDecay() {
        engine.output = AKDistortion(input, decay: 2)
        AKTest()
    }

    func testDecimation() {
        engine.output = AKDistortion(input, decimation: 0.61)
        AKTest()
    }

    func testDecimationMix() {
        engine.output = AKDistortion(input, decimationMix: 0.62)
        AKTest()
    }

    func testDefault() {
        engine.output = AKDistortion(input)
        AKTest()
    }

    func testDelay() {
        engine.output = AKDistortion(input, delay: 0.2)
        AKTest()
    }

    func testDelayMix() {
        engine.output = AKDistortion(input, delayMix: 0.6)
        AKTest()
    }

    func testFinalMix() {
        engine.output = AKDistortion(input, finalMix: 0.69)
        AKTest()
    }

    func testLinearTerm() {
        engine.output = AKDistortion(input, linearTerm: 0.63)
        AKTest()
    }

    func testParameters() {
        engine.output = AKDistortion(input,
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
        engine.output = AKDistortion(input, polynomialMix: 0.66)
        AKTest()
    }

    func testRingModBalance() {
        engine.output = AKDistortion(input, ringModBalance: 0.67, ringModMix: 0.68)
        AKTest()
    }

    func testRingModFreq1() {
        engine.output = AKDistortion(input, ringModFreq1: 200, ringModMix: 0.68)
        AKTest()
    }

    func testRingModFreq2() {
        engine.output = AKDistortion(input, ringModFreq2: 300, ringModMix: 0.68)
        AKTest()
    }

    func testRingModMix() {
        engine.output = AKDistortion(input, ringModMix: 0.68)
        AKTest()
    }

    func testRounding() {
        engine.output = AKDistortion(input, rounding: 0.5)
        AKTest()
    }

    func testSquaredTerm() {
        engine.output = AKDistortion(input, squaredTerm: 0.64)
        AKTest()
    }

    func testSoftClipGain() {
        engine.output = AKDistortion(input, softClipGain: 0)
        AKTest()
    }

}
