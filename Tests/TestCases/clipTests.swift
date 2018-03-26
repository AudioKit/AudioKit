//
//  clipTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class ClipTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testClip() {
        output = AKOperationEffect(input) { input, _ in
            return input.clip(0.5)
        }
        AKTestMD5("6e185ee7bcaa6ff0b0204bb6be9d65de")
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.clip()
        }
        AKTestMD5("52883a45c0394302b512a0ba71d2b4db")
    }

}
