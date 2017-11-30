//
//  AKTremoloTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKTremoloTests: AKTestCase {

    func testDefault() {
        output = AKTremolo(input)
        AKTestMD5("77fc5be08f1a46f4106fc88e5573c632")
    }

    func testFrequency() {
        output = AKTremolo(input, frequency: 20)
        AKTestMD5("5d33fc3f7bd4f467c464fa51cb7edbd5")
    }
}
