// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKReverbTests: AKTestCase {

    func testBypass() {
        let reverb = AKReverb(input)
        reverb.bypass()
        engine.output = reverb

        AKTestNoEffect()
    }

    #if os(iOS)

    func testCathedral() {
        let effect = AKReverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.cathedral)
        AKTest()
    }

    func testDefault() {
        engine.output = AKReverb(input)
        AKTest()
    }

    func testSmallRoom() {
        let effect = AKReverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.smallRoom)
        AKTest()
    }
    #endif

}
