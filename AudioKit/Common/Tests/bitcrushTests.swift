//
//  bitcrushTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class bitcrushTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush()
        }
        AKTestMD5("7a7cc018565b8f99afac21bb6182cbce")
    }

}
