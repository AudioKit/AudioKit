// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDiodeClipperTests: AKTestCase {

    func testDefault() {
        output = AKDiodeClipper(input)
        AKTestMD5("b4506e9954654342342546d932b52ec9")
    }

    func testParameters1() {
        output = AKDiodeClipper(input, cutoffFrequency: 1000, gain: 1.0)
        AKTestMD5("e7db57dd0bf283cb431b67cd3879ad80")
    }

    func testParameters2() {
        output = AKDiodeClipper(input, cutoffFrequency: 2000, gain: 2.0)
        AKTestMD5("8ca2025ba719314988d7c2b6e398f335")
    }

}
