//
//  AKVariableDelayTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKVariableDelayTests: AKTestCase {
    
    override func setUp() {
        super.setUp()
        duration = 2.0 // needs to be this long since the default time is one second
    }
    
    func testDefault() {
        let input = AKOscillator()
        output = AKVariableDelay(input)
        input.start()
        AKTestMD5("9df204fbc98bb8965081cb30a89715fc")
    }
    
    func testParametersSetOnInit() {
        let input = AKOscillator()
        output = AKVariableDelay(input, time: 0.1234, feedback: 0.95)
        input.start()
        AKTestMD5("9fe86f1214b9565512ac96c049884247")
    }
    
    func testParametersSetAfterInit() {
        let input = AKOscillator()
        let effect = AKVariableDelay(input)
        effect.time = 0.1234
        effect.feedback = 0.95
        output = effect
        input.start()
        AKTestMD5("9fe86f1214b9565512ac96c049884247")
    }


}
