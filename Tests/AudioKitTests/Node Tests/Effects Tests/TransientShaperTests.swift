// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TransientShaperTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = TransientShaper(player)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testplayerAmount() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = TransientShaper(player, inputAmount: -20.0)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testOutputAmount() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = TransientShaper(player, outputAmount: -20.0)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    /* Intermittent Tests
     
    func testAttackAmount() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = TransientShaper(player, attackAmount: 1.0)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testReleaseAmount() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = TransientShaper(player, releaseAmount: 1.0)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
 */

    /* This produces different MD5s on local machines vs CI
    func testParameters() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
         let player = AudioPlayer(url: url)!
        engine.output = TransientShaper(player,
                                        playerAmount: -1.0,
                                        attackAmount: -3.0,
                                        releaseAmount: 1.0,
                                        outputAmount: 0.0)
        player.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    */

}
