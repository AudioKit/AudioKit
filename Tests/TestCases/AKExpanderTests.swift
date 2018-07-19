//
//  AKExpanderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKExpanderTests: AKTestCase {

    func testDefault() {
        output = AKExpander(input)
        AKTestMD5("025c0a9fdf87f47a13c1e8e97587e499")
    }
}
