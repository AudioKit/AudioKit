//
//  AKBandPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKBandPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBandPassFilter(input)
        input.start()
        AKTestMD5("fa2134fd6781f471aaaf243805448b52")
    }
}
