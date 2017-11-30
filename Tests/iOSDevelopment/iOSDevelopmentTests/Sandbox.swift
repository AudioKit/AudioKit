//
//  Sandbox.swift
//  iOSDevelopmentTests
//
//  Created by Aurelius Prochazka on 11/29/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

import AudioKit
import XCTest

class Sandbox: AKTestCase {

    func testDefault() {
        output = input
        AKTestNoEffect()
    }

    func testParameters() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input
        AKTestMD5("857cc2e5bd6ed2b8387966cadf44c9c1")
    }
}

