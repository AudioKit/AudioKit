// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PlaygroundOscTests: XCTestCase {
    func testSquare() {
        let engine = AudioEngine()
        engine.output = PlaygroundOscillator(waveform: Table(.square))
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        XCTAssertEqual(audio.md5, "0118dbf3e33bc3052f2e375f06793c5f")
    }
    
    func testTriangle() {
        let engine = AudioEngine()
        engine.output = PlaygroundOscillator(waveform: Table(.triangle))
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        XCTAssertEqual(audio.md5, "789c1e77803a4f9d10063eb60ca03cea")
    }
    
    func testAmplitude() {
        let engine = AudioEngine()
        engine.output = PlaygroundOscillator(waveform: Table(.triangle), amplitude: 0.1)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        XCTAssertEqual(audio.md5, "8d1ece9eb2417d9da48f5ae796a33ac2")
    }
}
