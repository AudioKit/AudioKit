// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKRhodesPianoKeyTests: AKTestCase {

    func testRhodesPiano() {

        let rhodesPiano = AKRhodesPianoKey()
        rhodesPiano.trigger(note: 69)
        output = rhodesPiano

        // auditionTest()
        AKTestMD5("ed6b966db1f452e7f98a911d46bcc29b")

    }

    func testAmplitude() {

        let rhodesPiano = AKRhodesPianoKey()
        rhodesPiano.trigger(note: 69, velocity: 64)
        output = rhodesPiano

        // auditionTest()
        AKTestMD5("487dbe47fe2384504aaa895b65b90a27")

    }

}
