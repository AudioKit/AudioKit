//
//  AKReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKReverbTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKReverb(input)
        input.start()
        AKTestMD5("85cf66a4a60a8910a11b9e0188452e8b")
    }

    func testCathedral() {
        let input = AKOscillator()
        let effect = AKReverb(input)
        output = effect
        input.start()
        effect.loadFactoryPreset(.cathedral)
        AKTestMD5("db9e5c29696457cefd6b7525be6a6cbc")
    }

    func testSmallRoom() {
        let input = AKOscillator()
        let effect = AKReverb(input)
        output = effect
        input.start()
        effect.loadFactoryPreset(.smallRoom)
        AKTestMD5("6a45dbf872a4de21675e008ea4bf757c")
    }

}
