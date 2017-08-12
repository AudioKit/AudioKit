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

    func testCathedral() {
        let effect = AKReverb(input)
        output = effect
        effect.loadFactoryPreset(.cathedral)
        AKTestMD5("7281cc33badbdeec0280dc1711bb92ce")
    }

    func testDefault() {
        output = AKReverb(input)
        AKTestMD5("b9351188e123ed02502c7a5559a1499c")
    }

    func testSmallRoom() {
        let effect = AKReverb(input)
        output = effect
        effect.loadFactoryPreset(.smallRoom)
        AKTestMD5("da887657fae100779db2f244ee142638")
    }

}
