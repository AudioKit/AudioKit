//
//  sawtoothTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class sawtoothTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.sawtooth()
        }
        AKTestMD5("0b3fff37bccfc2ce47622192bfe9386f")
    }

}
