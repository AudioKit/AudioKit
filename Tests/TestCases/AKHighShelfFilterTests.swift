// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighShelfFilterTests: AKTestCase {

    func testDefault() {
        output = AKHighShelfFilter(input)
        AKTestNoEffect()
    }

    func testGain() {
        output = AKHighShelfFilter(input, gain: 1)
        AKTestMD5("a3e0e254d8e615aa7680e6ac21487a0b")
    }

    func testParameters() {
        output = AKHighShelfFilter(input, cutOffFrequency: 400, gain: 1)
        AKTestMD5("46b3c7449912abb6a5484ad7db9d3e9c")
    }

}
