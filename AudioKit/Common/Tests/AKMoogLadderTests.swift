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
        AKTestMD5("d35b507249824188ed4907dd5ae243f2")
    }
}
