// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKZitaReverbTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKZitaReverb(input)
        AKTestMD5("8910ee130583a9702c5eb27c65ef09a3")
    }

    func testParametersSetAfterInit() {
        let effect = AKZitaReverb(input)
        effect.rampDuration = 0
        effect.predelay.value = 10
        effect.crossoverFrequency.value = 200
        effect.lowReleaseTime.value = 1.5
        effect.midReleaseTime.value = 1.0
        effect.dampingFrequency.value = 3_000
        effect.equalizerFrequency1.value = 300
        effect.equalizerLevel1.value = 1
        effect.equalizerFrequency2.value = 1_400
        effect.equalizerLevel2.value = -1
        effect.dryWetMix.value = 0.5
        output = effect
        AKTestMD5("b824be4839f14474fb80eca60da317f7")
    }

    func testParametersSetOnInit() {
        output = AKZitaReverb(input,
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

        AKTestMD5("b824be4839f14474fb80eca60da317f7")
    }

}
