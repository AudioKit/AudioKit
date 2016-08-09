//
//  AKCostelloReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKCostelloReverbTests: AKTestCase {
    
    func testDefault() {
        let input = AKOscillator()
        output = AKCostelloReverb(input)
        input.start()
        AKTestMD5("733e06429e397e54f78f24263b8c8f6c")
    }
    
    func testParametersSetOnInit() {
        let input = AKOscillator()
        output = AKCostelloReverb(input,
                                  cutoffFrequency: 1234,
                                  feedback: 0.95)
        input.start()
        AKTestMD5("7aca506cee500b0c1ef5b3edbe4bfcb6")
    }
    
    func testParametersSetAfterInit() {
        let input = AKOscillator()
        let effect = AKCostelloReverb(input)
        effect.cutoffFrequency = 1234
        effect.feedback = 0.95
        output = effect
        input.start()
        AKTestMD5("7aca506cee500b0c1ef5b3edbe4bfcb6")
    }
}
