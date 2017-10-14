//
//  sawtoothTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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
        AKTestMD5("1c5d51da02f6727c16074976e24a2010")
    }

}
