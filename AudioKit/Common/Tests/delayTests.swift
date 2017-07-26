//
//  delayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class DelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 3.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay()
        }
        AKTestMD5("b93e998c1fddbc87fbcdb7d3321848f1")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01, feedback: 0.99)
        }
        AKTestMD5("04efda97dbb8478ecbadafc93c6a2024")
    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01)
        }
        AKTestMD5("7c824e1a3f8819b87fcc2787557e2769")
    }

//    func testFeedback() {
//        output = AKOperationEffect(input) { input, _ in
//            return input.delay(feedback: 0.99)
//        }
//        AKTestMD5("3b4fff253492b5f02c117552b1e7d49e")
//    }
}

