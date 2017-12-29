//
//  sawtoothTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class SawtoothTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.sawtooth()
        }
        AKTestMD5("582e76f338bafc30a1a0954313891a5e")
    }

}
