//
//  AKMoogLadderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKMoogLadderTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKMoogLadder(input)
        input.start()
        AKTestMD5("abe11090068d5b9eb05a3d0e94d381e8")
    }
}
