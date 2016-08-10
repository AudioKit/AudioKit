//
//  reverberateWithChowningTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class reverberateWithChowningTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.reverberateWithChowning()
        }
        AKTestMD5("a5a29af55e26f1d5376f0c96b5bc9f87")
    }

}
