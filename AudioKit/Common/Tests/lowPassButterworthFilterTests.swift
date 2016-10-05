//
//  lowPassButterworthFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class lowPassButterworthFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.lowPassButterworthFilter()
        }
        AKTestMD5("9f8bed0d6eef69e8761fc9f90ab0ae69")
    }

}
