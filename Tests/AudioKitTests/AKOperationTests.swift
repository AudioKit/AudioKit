// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
@testable import AudioKit

class AKOperationTests: XCTestCase {

    func testSine() {
                
        let sine = AKOperation.sineWave(frequency: 1)
        XCTAssertEqual(sine.sporth, " \n1 1 sine  \n")
        
    }
}
