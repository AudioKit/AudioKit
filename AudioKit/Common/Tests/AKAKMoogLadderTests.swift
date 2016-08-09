//
//  AKMoogLadderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKMoogLadderTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKMoogLadder(input)
        input.start()
        AKTestMD5("ef06eaa675482639297c84b83712111a")
    }
}
