// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation

class AKBoosterTests: AKTestCase {

    func testDefault() {
        output = AKBooster(input)
        AKTestNoEffect()
    }

    func testBypass() {
        let booster = AKBooster(input, gain: 2.0)
        booster.bypass()
        output = booster
        AKTestNoEffect()
    }

    func testParameters() {
        output = AKBooster(input, gain: 2.0)
        AKTest()
    }

    func testParameters2() {
        output = AKBooster(input, gain: 0.5)
        AKTest()
    }

}
