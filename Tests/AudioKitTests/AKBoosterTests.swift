// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation

class AKBoosterTests: AKTestCase {

    func testDefault() {
        engine.output = AKBooster(input)
        AKTestNoEffect()
    }

    func testBypass() {
        let booster = AKBooster(input, gain: 2.0)
        booster.bypass()
        engine.output = booster
        AKTestNoEffect()
    }

    func testParameters() {
        engine.output = AKBooster(input, gain: 2.0)
        AKTest()
    }

    func testParameters2() {
        engine.output = AKBooster(input, gain: 0.5)
        AKTest()
    }

}
