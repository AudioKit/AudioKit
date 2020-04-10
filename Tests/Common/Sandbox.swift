// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
        AKTestMD5("615e742bc1412c15237a453c5b49d5e0")
    }
}
