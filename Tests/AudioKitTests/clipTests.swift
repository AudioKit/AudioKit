// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class ClipTests: AKTestCase2 {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testClip() {
        output = AKOperationEffect(input) { $0.clip(0.5) }
        AKTest()
    }

    func testDefault() {
        output = AKOperationEffect(input) { $0.clip() }
        AKTest()
    }

}
