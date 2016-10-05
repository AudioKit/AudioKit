//
//  phasorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class phasorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.phasor()
        }
        AKTestMD5("3158517a6a14167e736cf7038a828dc8")
    }

}
