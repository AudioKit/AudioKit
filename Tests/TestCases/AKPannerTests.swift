//
//  AKPannerTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPannerTests: AKTestCase {

    func testDefault() {
        output = AKPanner(input)
        AKTestMD5("33dcb14448f8bda9174797a47178cd9f")
    }

    func testBypass() {
        let pan = AKPanner(input, pan: -1)
        pan.bypass()
        output = pan
        AKTestNoEffect()
    }

    func testPanLeft() {
        output = AKPanner(input, pan: -1)
        AKTestMD5("f1a562907d9bcc8af6463d75633a14c2")
    }

    func testPanRight() {
        output = AKPanner(input, pan: 1)
        AKTestMD5("6b75baedc4700e335f665785e8648c14")
    }
}
