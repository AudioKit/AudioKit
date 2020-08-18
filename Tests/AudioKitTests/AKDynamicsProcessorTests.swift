// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDynamicsProcessorTests: AKTestCase {

    func testDefault() {
        output = AKDynamicsProcessor(input)
        AKTestMD5("0a3ded76baa047969bb90eae8fc1f7a9")
    }

}
