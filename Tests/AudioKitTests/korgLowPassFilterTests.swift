// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class KorgLowPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        engine.output = AKOperationEffect(input) { $0.korgLowPassFilter() }
        AKTest()
    }

    func testParameters() {
        engine.output = AKOperationEffect(input) { input in
            return input.korgLowPassFilter(cutoffFrequency: 2_000, resonance: 0.9, saturation: 0.5)
        }
        AKTest()
    }

}
