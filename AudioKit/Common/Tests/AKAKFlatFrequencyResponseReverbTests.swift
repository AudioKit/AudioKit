//
//  AKFlatFrequencyResponseReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKFlatFrequencyResponseReverb(input)
        input.start()
        AKTestMD5("bb236a2f697859030b98c75742764802")
    }
}
