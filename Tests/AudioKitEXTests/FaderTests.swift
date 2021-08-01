// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitEX
import XCTest

class FaderTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = Fader(player, gain: 1.0)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testGain() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = Fader(player, gain: 0.5)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBypass() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let fader = Fader(player, gain: 2.0)
        fader.bypass()
        engine.output = fader
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMany() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let initialFader = Fader(player, gain: 1.0)
        var nextFader = initialFader
        for _ in 0 ..< 200 {
            let fader = Fader(nextFader, gain: 1.0)
            nextFader = fader
        }
        engine.output = nextFader
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    
    /*

    func testFlipStereo() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let pan = Panner(player, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.flipStereo = true
        engine.output = fader
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }


    func testFlipStereoTwice() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let pan = Panner(player, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = Fader(fader, gain: 1.0)
        fader2.flipStereo = true
        engine.output = fader2
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereoThrice() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let pan = Panner(player, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = Fader(fader, gain: 1.0)
        fader2.flipStereo = true
        let fader3 = Fader(fader2, gain: 1.0)
        fader3.flipStereo = true
        engine.output = fader3
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMixToMono() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let pan = Panner(player, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.mixToMono = true
        engine.output = fader
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
*/

    func testParameters() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = Fader(player, gain: 2.0)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters2() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = Fader(player, gain: 0.5)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRealtimeRamp() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let fader = Fader(player)

        engine.output = fader

        try? engine.start()

        fader.start()
        player.play()

        fader.$leftGain.ramp(from: 0, to: 1, duration: Float(player.duration))
        fader.$rightGain.ramp(from: 0, to: 1, duration: Float(player.duration))

        wait(for: player.duration + 0.5)

    }

    // for waiting in the background for realtime testing
    func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }
}
