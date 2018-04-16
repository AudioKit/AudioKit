//
//  phasorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class PhasorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.phasor()
        }
        AKTestMD5("3158517a6a14167e736cf7038a828dc8")
    }

}
