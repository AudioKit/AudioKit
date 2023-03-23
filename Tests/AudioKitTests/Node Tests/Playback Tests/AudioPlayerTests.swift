// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {

    func testDefault() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: URL.testAudio)
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testRate() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: URL.testAudio)
        player.rate = 2
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testPitch() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: URL.testAudio)
        player.pitch = 1200
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

}
