// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChowningReverbTests: AKTestCase2 {

    func testDefault() {
        output = AKChowningReverb(input)
        AKTest()
    }

}
