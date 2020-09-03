// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKZitaReverbTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        engine.output = AKZitaReverb(input)
        AKTest()
    }

    func testParametersSetAfterInit() {
        let effect = AKZitaReverb(input)
        effect.rampDuration = 0
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
        AKTest()
    }

    func testParametersSetOnInit() {
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

        AKTest()
    }

}
