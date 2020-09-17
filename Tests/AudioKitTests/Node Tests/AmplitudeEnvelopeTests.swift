// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AmplitudeEnvelopeTests: XCTestCase {

    func testAttack() {
        let engine = AudioEngine()
        let input = Oscillator()
        let envelope = AmplitudeEnvelope(input, attackDuration: 0.123_4)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecay() {
        let engine = AudioEngine()
        let input = Oscillator()
        let envelope = AmplitudeEnvelope(input, decayDuration: 0.234, sustainLevel: 0.345)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator()
        let envelope = AmplitudeEnvelope(input)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator()
        let envelope = AmplitudeEnvelope(input, attackDuration: 0.123_4, decayDuration: 0.234, sustainLevel: 0.345)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSustain() {
        let engine = AudioEngine()
        let input = Oscillator()
        let envelope = AmplitudeEnvelope(input, sustainLevel: 0.345)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    // Release is not tested at this time since there is no sample accurate way to define release point

}
