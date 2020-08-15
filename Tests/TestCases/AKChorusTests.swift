// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChorusTests: AKTestCase {

    func testParameters() {
        output = AKChorus(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTestMD5("35e3290ff7046179cc267153153b0e7e")
    }
}

