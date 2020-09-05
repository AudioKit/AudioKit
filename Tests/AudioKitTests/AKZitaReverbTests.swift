// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKZitaReverbTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKZitaReverb(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AKEngine()
        let input = AKOscillator()
        let effect = AKZitaReverb(input)
        effect.predelay = 10
        effect.crossoverFrequency = 200
        effect.lowReleaseTime = 1.5
        effect.midReleaseTime = 1.0
        effect.dampingFrequency = 3_000
        effect.equalizerFrequency1 = 300
        effect.equalizerLevel1 = 1
        effect.equalizerFrequency2 = 1_400
        effect.equalizerLevel2 = -1
        effect.dryWetMix = 0.5
        engine.output = effect
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetOnInit() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKZitaReverb(input,
                              predelay: 10,
                              crossoverFrequency: 200,
                              lowReleaseTime: 1.5,
                              midReleaseTime: 1.0,
                              dampingFrequency: 3_000,
                              equalizerFrequency1: 300,
                              equalizerLevel1: 1,
                              equalizerFrequency2: 1_400,
                              equalizerLevel2: -1,
                              dryWetMix: 0.5)

        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
