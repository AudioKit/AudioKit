// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChowningReverbTests: AKTestCase {

    func testDefault() {
        output = AKChowningReverb(input)
        AKTest()
    }

}
