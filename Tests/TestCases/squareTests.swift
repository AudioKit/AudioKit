//
//  squareTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class SquareTests: AKTestCase {

    let square = AKOperationGenerator { _ in return AKOperation.square() }

    override func setUp() {
        afterStart = { self.square.start() }
        duration = 1.0
    }

    func testDefault() {
        output = square
        AKTestMD5("008643a12bbc8fbca8c65e9787e3825d")
    }

}
