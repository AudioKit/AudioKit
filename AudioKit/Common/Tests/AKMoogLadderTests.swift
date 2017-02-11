//
//  AKMoogLadderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKMoogLadderTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKMoogLadder(input)
        input.start()
        AKTestMD5("d35b507249824188ed4907dd5ae243f2")
    }
}
