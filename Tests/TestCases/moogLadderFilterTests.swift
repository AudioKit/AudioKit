//
//  moogLadderFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class MoogLadderFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.moogLadderFilter()
        }
        AKTestMD5("76c9a16a1976ba8618c3f4df27856c81")
    }

}
