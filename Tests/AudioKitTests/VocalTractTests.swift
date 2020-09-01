// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class VocalTractTests: AKTestCase {

    var vocalTract = AKOperationGenerator { AKOperation.vocalTract() }

    override func setUp() {
        afterStart = { self.vocalTract.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = vocalTract
        AKTest()
    }

    func testParameterSweep() {
        vocalTract = AKOperationGenerator {
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: duration)
            return AKOperation.vocalTract(frequency: 200 + 200 * line,
                                          tonguePosition: line,
                                          tongueDiameter: line,
                                          tenseness: line,
                                          nasality: line)
        }
        engine.output = vocalTract
        AKTest()
    }

}
