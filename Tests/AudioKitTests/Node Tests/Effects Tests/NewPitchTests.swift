// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFAudio

final class NewPitchTests: XCTestCase {
    let engine = AudioEngine()
    let newPitch = NewPitch(ConstantGenerator(constant: 1))

    override func setUp() {
        super.setUp()
        engine.output = newPitch
    }

    func testSetAndGetPitch() {
        newPitch.pitch = 200
        XCTAssertEqual(newPitch.pitch, 200)

        newPitch.pitch = -300
        XCTAssertEqual(newPitch.pitch, -300)

        newPitch.pitch = 1
        XCTAssertEqual(newPitch.pitch, 1)
    }

    // This serves as a smoke test
    // in case future OS versions change the default.
    func testDefaultValue() {
        XCTAssertEqual(newPitch.pitch, 0)
    }
}
