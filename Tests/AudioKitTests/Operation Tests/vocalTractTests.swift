// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class VocalTractOperationTests: XCTestCase {

    let vocalTract = OperationGenerator { AKOperation.vocalTract() }

    func testDefault() {
        let engine = AudioEngine()
        let vocalTract = OperationGenerator { AKOperation.vocalTract() }
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameterSweep() {
        let engine = AudioEngine()
        let vocalTract = OperationGenerator {
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: 1.0)
            return AKOperation.vocalTract(frequency: 200 + 200 * line,
                                          tonguePosition: line,
                                          tongueDiameter: line,
                                          tenseness: line,
                                          nasality: line)
        }
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
