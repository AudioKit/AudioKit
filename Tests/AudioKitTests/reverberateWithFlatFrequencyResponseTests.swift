// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class ReverberateWithFlatFrequencyResponseTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.reverberateWithFlatFrequencyResponse()
        }
        AKTestMD5("81986911704e817a55f6259c3dc94904")
    }

}
