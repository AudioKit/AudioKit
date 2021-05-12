// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import AudioKit
import XCTest
import CAudioKit

class SynthTests: XCTestCase {

    func testChord() {
        let engine = AudioEngine()
        let synth = Synth()
        engine.output = synth
        let audio = engine.startTest(totalDuration: 1.0)
        synth.play(noteNumber: 64, velocity: 120)
        synth.play(noteNumber: 67, velocity: 120)
        synth.play(noteNumber: 71, velocity: 120)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMonophonicPlayback() {
        let engine = AudioEngine()
        let synth = Synth()
        engine.output = synth
        let audio = engine.startTest(totalDuration: 2.0)
        synth.play(noteNumber: 64, velocity: 120)
        audio.append(engine.render(duration: 1.0))
        synth.stop(noteNumber: 64)
        synth.play(noteNumber: 65, velocity: 120)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameterInitialization() {
        let engine = AudioEngine()
        let synth = Synth(masterVolume: 0.9,
                          pitchBend: 0.1,
                          vibratoDepth: 0.2,
                          filterCutoff: 40,
                          filterStrength: 19,
                          filterResonance: 0.11,
                          attackDuration: 0.05,
                          decayDuration: 0.2,
                          sustainLevel: 0.5,
                          releaseDuration: 0.5,
                          filterEnable: true,
                          filterAttackDuration: 0.13,
                          filterDecayDuration: 0.19,
                          filterSustainLevel: 0.4,
                          filterReleaseDuration: 0.43)
        engine.output = synth
        let audio = engine.startTest(totalDuration: 2.0)
        synth.play(noteNumber: 64, velocity: 120)
        audio.append(engine.render(duration: 1.0))
        synth.stop(noteNumber: 64)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
#endif
