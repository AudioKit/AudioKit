// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {

    func testDefault() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: .testAudio)
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testRate() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: .testAudio)
        player.rate = 2
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testPitch() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: .testAudio)
        player.pitch = 1200
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testLoop() {
        let engine = Engine()
        let player = AudioPlayer()
        player.load(url: .testAudio)
        player.isLooping = true
        player.loopStart = 2.0
        player.loopDuration = 1.0
        engine.output = player

        player.play()
        let audio = engine.startTest(totalDuration: 3.0)
        audio.append(engine.render(duration: 3.0))
        testMD5(audio)
    }

}
