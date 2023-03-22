// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {

    func testAudioPlayer() {
        let engine = Engine()
        let player = AudioPlayer()
        engine.output = player
        player.play(url: URL.testAudio)
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
        // audio.audition()
    }
}
