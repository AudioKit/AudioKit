// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AmplitudeEnvelopeTests: XCTestCase {

    func testAttack() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
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
        let input = Oscillator(waveform: Table(.triangle))
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
        let input = Oscillator(waveform: Table(.triangle))
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
        let input = Oscillator(waveform: Table(.triangle))
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
        let input = Oscillator(waveform: Table(.triangle))
        let envelope = AmplitudeEnvelope(input, sustainLevel: 0.345)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRelease() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let envelope = AmplitudeEnvelope(input, releaseDuration: 0.5)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        envelope.stop()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDoubleStop() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let envelope = AmplitudeEnvelope(input, releaseDuration: 0.5)
        engine.output = envelope
        input.play()
        envelope.start()

        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        envelope.stop()
        audio.append(engine.render(duration: 0.5))
        envelope.stop()
        audio.append(engine.render(duration: 0.5))
        testMD5(audio)
    }

}
