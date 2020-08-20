// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
@testable import AudioKit

class AKOperationTests: XCTestCase {

    func testDelay() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let delay = operation.delay(time: 1.2, feedback: 1.3)
        XCTAssertEqual(delay.sporth, "\"ak\" \"0\" gen_vals 1.1 2.2 sine 0 \"ak\" tset 0 \"ak\" tget 1.3 1.2 delay ")
    }
    
    func testSineWave() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        XCTAssertEqual(operation.sporth, "1.1 2.2 sine ")
    }
}
