// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDynamicsProcessorTests: AKTestCase {

    func testDefault() {
        output = AKDynamicsProcessor(input)
        AKTest()
    }

}
