//
//  lowPassButterworthFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class  LowPassButterworthFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.lowPassButterworthFilter()
        }
        AKTestMD5("7bff62372f2a7b36a0e9193646bf84e9")
    }

}
