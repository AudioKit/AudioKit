// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTubularBellsTests: AKTestCase {

    func testTubularBells() {

        let bells = AKTubularBells()
        bells.trigger(frequency: 440)
        output = bells

        // auditionTest()
        AKTestMD5("6b07b92863e0f2b3dfdd25387548fd0c")

    }

    func testAmplitude() {

        let bells = AKTubularBells()
        bells.trigger(frequency: 440, amplitude: 0.5)
        output = bells

        // auditionTest()
        AKTestMD5("a33e043c60217055ca3af93b4e153277")

    }

}
