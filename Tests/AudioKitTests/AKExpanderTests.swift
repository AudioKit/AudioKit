// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKExpanderTests: AKTestCase2 {

    func testDefault() {
        output = AKExpander(input)
        AKTest()
    }
}
