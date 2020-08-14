// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKRhodesPianoTests: AKTestCase {

    func testRhodesPiano() {

        let rhodesPiano = AKRhodesPiano()
        rhodesPiano.trigger(frequency: 440)
        output = rhodesPiano

        // auditionTest()
        AKTestMD5("7f399d5145084b9ba57270501a19570e")

    }

    func testAmplitude() {

        let rhodesPiano = AKRhodesPiano()
        rhodesPiano.trigger(frequency: 440, amplitude: 0.5)
        output = rhodesPiano

        // auditionTest()
        AKTestMD5("3a8e3c1fa5db6eb8629b39c11abc0443")

    }

}
