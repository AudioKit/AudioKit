// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKClipperTests: AKTestCase {

    func testDefault() {
        output = AKClipper(input)
        AKTestMD5("2084113bc50e7eca946d48ca608d3276")
    }

    func testParameters1() {
        output = AKClipper(input, limit: 0.1)
        AKTestMD5("a829fdfaf9c8912f3a060b4389a6b819")
    }

    func testParameters2() {
        output = AKClipper(input, limit: 0.5)
        AKTestMD5("419dbbd117255b0856047e0565a079ba")
    }

}
