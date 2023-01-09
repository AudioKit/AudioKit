// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFAudio

class AmplitudeDectorTests: XCTestCase {

    func testDefault() {

        let sr = 44100
        for i in 0..<10 {

            // One second of noise.
            let noise: [Float] = (0..<sr).map { _ in
                Float.random(in: -1...1) * Float(i) * 0.1
            }

            let amp = detectAmplitude(noise)

            XCTAssertEqual(amp, 0.579 * Float(i) * 0.1, accuracy: 0.03)
        }

    }

}
