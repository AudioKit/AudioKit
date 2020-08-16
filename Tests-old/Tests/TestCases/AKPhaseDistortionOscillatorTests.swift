// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPhaseDistortionOscillatorTests: AKTestCase {

    var oscillator = AKPhaseDistortionOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
        AKDebugDSPSetActive(true)
    }

    func testDefault() {
        output = oscillator
        AKTestMD5("9bb6df5a3b0bd5587b19e6acf8f6943d")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "2ff3c2b55ba0f31085eb8fded5e7ff7a"))
    }

    func testParameters() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square),
                                                 frequency: 1_234,
                                                 amplitude: 0.5,
                                                 phaseDistortion: 1.234,
                                                 detuningOffset: 1.234,
                                                 detuningMultiplier: 1.1)
        XCTAssertEqual(oscillator.frequency, 1_234)
        XCTAssertEqual(oscillator.amplitude, 0.5)
        XCTAssertEqual(oscillator.phaseDistortion, 1.234)
        XCTAssertEqual(oscillator.detuningOffset, 1.234)
        XCTAssertEqual(oscillator.detuningMultiplier, 1.1)
        output = oscillator
        AKTestMD5("2e01df8582f3357dd0886066b09eaba9")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "bf40b85d74114c4b9761b90469ad9dd2"))
    }

    func testFrequency() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), frequency: 1_234)
        output = oscillator
        AKTestMD5("095709fff34023e66b3f27e2f97d6dbd")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "80f775510e85d64e360e2725dab355d9"))
    }

    func testAmplitude() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), amplitude: 0.5)
        output = oscillator
        AKTestMD5("4eeefb56d24b9ad39ec824e34acdcd55")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "2ff3c2b55ba0f31085eb8fded5e7ff7a"))
    }

    func testPhaseDistortion() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), phaseDistortion: 1.234)
        output = oscillator
        AKTestMD5("066f3baeb08af73a5d9ae909a7b43a4e")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "2ff3c2b55ba0f31085eb8fded5e7ff7a"))
    }

    func testDetuningOffset() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), detuningOffset: 1.234)
        output = oscillator
        AKTestMD5("a63567f271a6d1d5d6b2ba22e80d64ca")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "65fb399238a46d3180b560ee73a358ca"))
    }

    func testDetuningMultiplier() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), detuningMultiplier: 1.1)
        output = oscillator
        AKTestMD5("78244cdf0afa2e3030205cebf175e024")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "e1a0a11d757649305cc894e3e22be4a1"))
    }

    func testParametersSetAfterInit() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square))
        oscillator.rampDuration = 0.0
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.phaseDistortion = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.1
        output = oscillator
        AKTestMD5("2e01df8582f3357dd0886066b09eaba9")
        XCTAssertTrue(AKDebugDSPCheck(AKPhaseDistortionOscillatorDebugPhase, "bf40b85d74114c4b9761b90469ad9dd2"))
    }
}
