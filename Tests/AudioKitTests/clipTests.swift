// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class ClipTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testClip() {
        engine.output = AKOperationEffect(input) { $0.clip(0.5) }
        AKTest()
    }

    func testDefault() {
        engine.output = AKOperationEffect(input) { $0.clip() }
        AKTest()
    }

}
