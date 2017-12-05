//
//  reverberateWithCostelloTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class ReverberateWithCostelloTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.reverberateWithCostello()
        }
        AKTestMD5("55c6eee38a8133299e47a9d3a570b118")
    }

}
