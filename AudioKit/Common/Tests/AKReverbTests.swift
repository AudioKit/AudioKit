//
//  AKReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKReverbTests: AKTestCase {
    
    func testDefault() {
        let input = AKOscillator()
        output = AKReverb(input)
        input.start()
        AKTestMD5("48eba6bcafdd47ce2705120273f739df")
    }
    
    func testCathedral() {
        let input = AKOscillator()
        let effect = AKReverb(input)
        output = effect
        input.start()
        effect.loadFactoryPreset(.Cathedral)
        AKTestMD5("670a8fe1d0216d0678750dab47d2118d")
    }
    
    func testSmallRoom() {
        let input = AKOscillator()
        let effect = AKReverb(input)
        output = effect
        input.start()
        effect.loadFactoryPreset(.SmallRoom)
        AKTestMD5("1bbea0f0f4319e68804196da9f177951")
    }

}
