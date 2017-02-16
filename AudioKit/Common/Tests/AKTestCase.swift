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

    var MD5: String {
        return AudioKit.tester!.MD5
    }

    func auditionTest() {
        AudioKit.auditionTest(node: output!, duration: duration)
    }

    func AKTestMD5(_ md5: String, alternate: String = "") {
        AudioKit.test(node: output!, duration: duration)
        let  localMD5 = MD5
        XCTAssertTrue([md5, alternate].contains(localMD5), localMD5)
    }

    override func setUp() {
        super.setUp()
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        AudioKit.stop()
        super.tearDown()
    }

}
