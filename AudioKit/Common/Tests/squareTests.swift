//
//  squareTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class squareTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.square()
        }
        AKTestMD5("7f69f2dfc4f6780825b5f7d18ad6516c")
    }

}
