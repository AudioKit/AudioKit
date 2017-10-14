//
//  squareTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class SquareTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.square()
        }
        AKTestMD5("522549cad1958e9e703cc6acde9b8b24")
    }

}
