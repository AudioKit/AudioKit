// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class  LowPassButterworthFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.lowPassButterworthFilter()
        }
        AKTestMD5("7bff62372f2a7b36a0e9193646bf84e9")
    }

}
