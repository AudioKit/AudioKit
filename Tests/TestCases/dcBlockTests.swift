//
//  dcBlockTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class DCBlockTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.dcBlock()
        }
        AKTestMD5("d2b120199019b639d5a7e2b3463e9c97")
    }

}
