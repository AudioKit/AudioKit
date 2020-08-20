// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKReverbTests: AKTestCase {

    #if os(iOS)

    func testBypass() {
        let reverb = AKReverb(input)
        reverb.bypass()
        output = reverb
        AKTestNoEffect()
    }

    func testCathedral() {
        let effect = AKReverb(input)
        output = effect
        effect.loadFactoryPreset(.cathedral)
        AKTest()
    }

    func testDefault() {
        output = AKReverb(input)
        AKTest()
    }

    func testSmallRoom() {
        let effect = AKReverb(input)
        output = effect
        effect.loadFactoryPreset(.smallRoom)
        AKTest()
    }
    #endif

}
