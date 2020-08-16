// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTubularBellsTests: AKTestCase {

    func testTubularBells() {

        let bells = AKTubularBells()
        bells.trigger(note: 69)
        output = bells

        // auditionTest()
        AKTestMD5("c8f43180f9daa01b148c3bb7a83d39c0")

    }

    func testAmplitude() {

        let bells = AKTubularBells()
        bells.trigger(note: 69, velocity: 64)
        output = bells

        // auditionTest()
        AKTestMD5("5b9e18cf26831053ff3345dca113cd48")

    }

}
