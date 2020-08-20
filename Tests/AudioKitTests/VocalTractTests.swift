// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class VocalTractTests: AKTestCase {

    var vocalTract = AKOperationGenerator { _ in return AKOperation.vocalTract() }

    override func setUp() {
        afterStart = { self.vocalTract.start() }
        duration = 1.0
    }

    func testDefault() {
        output = vocalTract
        AKTest()
    }

    func testParameterSweep() {
        vocalTract = AKOperationGenerator { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: self.duration)
            return AKOperation.vocalTract(frequency: 200 + 200 * line,
                                          tonguePosition: line,
                                          tongueDiameter: line,
                                          tenseness: line,
                                          nasality: line)
        }
        output = vocalTract
        AKTest()
    }

}
