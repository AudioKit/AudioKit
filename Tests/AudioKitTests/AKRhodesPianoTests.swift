// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKRhodesPianoKeyTests: AKTestCase {

    func testRhodesPiano() {

        let rhodesPiano = AKRhodesPianoKey()
        rhodesPiano.trigger(note: 69)
        engine.output = rhodesPiano

        AKTest()

    }

    func testAmplitude() {

        let rhodesPiano = AKRhodesPianoKey()
        rhodesPiano.trigger(note: 69, velocity: 64)
        engine.output = rhodesPiano

        AKTest()

    }

}
