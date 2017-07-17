//
//  bitcrushTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class BitcrushTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush()
        }
        AKTestMD5("cdd74d133dc647b69fb485f45acdef2c")
    }

    func testParameters() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(bitDepth: 7, sampleRate: 4000)
        }
        AKTestMD5("3bd599de5b30f9efd672aea4f77fa416")
    }

    func testBitDepth() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(bitDepth: 7)
        }
        AKTestMD5("85a80b4f358c1620ade7303671df5290")
    }

    func testSampleRate() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(sampleRate: 4000)
        }
        AKTestMD5("331061168ca350c4093dd40b488e19b2")
    }

}
