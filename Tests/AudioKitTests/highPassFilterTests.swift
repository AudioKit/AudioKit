// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class HighPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        engine.output = AKOperationEffect(input) { $0.highPassFilter() }
        AKTest()
    }

    func testHalfPowerPoint() {
        engine.output = AKOperationEffect(input) { $0.highPassFilter(halfPowerPoint: 100) }
        AKTest()
    }

}
