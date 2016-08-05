//
//  AKFMOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKFMOscillatorTests: AKTestCase {
    
    func testDefault() {
        output = AKFMOscillator()
        AKTestMD5("362f9f2f10f025ec8c798713e2bf6a2e")
    }
    
    func testSquareWave() {
        output = AKFMOscillator(waveform: AKTable(.Square, size: 4096))
        AKTestMD5("c6b194d7bf925ade38c3a1d5333326f8")
    }
}
