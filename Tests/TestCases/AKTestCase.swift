//
//  AKTestCase.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKTestCase: XCTestCase {

    var duration = 0.1
    var output: AKNode?

    let sineOscillatorMD5 = "6ee413495f949542432eb00d32ecd903"

    var input = AKOscillator()

    var MD5: String {
        return AudioKit.tester?.MD5 ?? ""
    }

    var afterStart: () -> Void = {}

    func auditionTest() {
        if let existingOutput = output {
            AudioKit.auditionTest(node: existingOutput, duration: duration)
        }
    }

    func AKTestMD5(_ md5: String, alternate: String = "") {
        if let existingOutput = output {
            AudioKit.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        let  localMD5 = MD5
        XCTAssertTrue([md5, alternate].contains(localMD5) && localMD5 != sineOscillatorMD5 && localMD5 != "", localMD5)
    }

    func AKTestMD5Not(_ md5: String) {
        if let existingOutput = output {
            AudioKit.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        let  localMD5 = MD5
        XCTAssertFalse(md5 == localMD5, localMD5)
    }

    func AKTestNoEffect() {
        if let existingOutput = output {
            AudioKit.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        let  localMD5 = MD5
        XCTAssertTrue(localMD5 == sineOscillatorMD5, localMD5)
    }

    override func setUp() {
        super.setUp()
        afterStart = { self.input.start() }
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        AudioKit.disconnectAllInputs()
        AudioKit.stop()
        super.tearDown()
    }

}
