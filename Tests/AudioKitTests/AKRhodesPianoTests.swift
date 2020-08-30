// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKRhodesPianoKeyTests: AKTestCase2 {

    func testRhodesPiano() {

        let rhodesPiano = AKRhodesPianoKey()
        rhodesPiano.trigger(note: 69)
        output = rhodesPiano

        // auditionTest()
        AKTest()

    }

    func testAmplitude() {

        let rhodesPiano = AKRhodesPianoKey()
        rhodesPiano.trigger(note: 69, velocity: 64)
        output = rhodesPiano

        // auditionTest()
        AKTest()

    }

}
