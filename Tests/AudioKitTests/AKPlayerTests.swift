import AudioKit
import AVFoundation
import XCTest

// XXX: Disable AKPlayerTests for now since SPM doesn't allow test resources until Xcode 12.
#if false

class AKPlayerTests: AKTestCase {
    // 12345 is good for testing editing, PinkNoise is good to check fade amplitudes
    static let pinkNoise = "PinkNoise"
    static let counting = "12345"

    // run the test, or just listen to it
    private var auditioning: Bool = false

    func testBasic() {
        testPlayer(md5: "b7d558f54ce7b1b2e08b705a3dff1e2f",
                   filename: AKPlayerTests.counting)
    }

    func testFadeInOut() {
        var fade = AKPlayer.Fade()
        fade.inTime = 1
        fade.outTime = 1
        testPlayer(md5: "9c133a9288e33e574552c40e9dec5e48",
                   fade: fade)
    }

    func testScheduledFadeInOut() {
        var fade = AKPlayer.Fade()
        fade.inTime = 0.5
        fade.outTime = 2
        // player will start 2 seconds into the future
        testPlayer(md5: "2681c654b92a82f12d97e77326484e85",
                   filename: AKPlayerTests.counting, when: 2, fade: fade)
    }

    func testScheduledOffsetFadeInOut() {
        var fade = AKPlayer.Fade()
        fade.inTime = 3
        fade.outTime = 3
        // player will start 1 second into the future, and 2 seconds into the 3 second fade
        testPlayer(md5: "cf3fadc31b675689719e07155bfd533a",
                   when: 1, fade: fade, interiorStartTime: 2)
    }

    /*
     // Changing the playback rate or pitch doesn't produce consistent md5's. Sometimes it's right, sometimes not
     // ???

     func testPitch() {
         testPlayer(md5: "a24d37741662aadc53127b0ffa508a1e",
                    filename: AKPlayerTests.counting,
                    pitch: -600)
     }

      func testRate() {
          testPlayer(md5: "980c76b26541a9c2650291c2d8b2d04f",
                     filename: AKPlayerTests.counting,
                     rate: 2)
      }

      func testPitchAndRate() {
          testPlayer(md5: "ce39f5847d2f361d98db44b2be0225c0",
                     filename: AKPlayerTests.counting,
                     rate: 2,
                     pitch: -600)
      }
      */

    func testEdited() {
        testPlayer(md5: "a5c1ee84ec7692b3fba09f4404e1fe0d",
                   filename: AKPlayerTests.counting,
                   from: 0.75, to: 4) // will say 2, 3, 4
    }

    /// Utility function to handle all basic AKPlayer options

    private func testPlayer(md5: String,
                            filename: String = pinkNoise,
                            from startingTime: TimeInterval = 0,
                            to endingTime: TimeInterval = 0,
                            when: TimeInterval = 0,
                            fade: AKPlayer.Fade? = nil,
                            rate: AUValue = 1,
                            pitch: AUValue = 0,
                            interiorStartTime offsetTime: TimeInterval = 0) {
        guard let url: URL = Bundle(for: AKPlayerTests.self)
            .url(forResource: filename, withExtension: "wav") else {
            XCTFail("Couldn't find URL")
            return
        }

        // we can use AKDynamicPlayer for all tests as it contains the most options
        guard let player = AKDynamicPlayer(url: url) else {
            XCTFail("Couldn't create AKDynamicPlayer.")
            return
        }

        var testDuration = player.duration
        var audioTime: AVAudioTime?

        if when > 0 {
            audioTime = AVAudioTime.now().offset(seconds: when)
            testDuration += when
        }

        /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0 and disabled)
        player.rate = rate

        /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0 and disabled)
        player.pitch = pitch

        // a hint for the player to know when you are starting playback
        // inside the audio. This is different than startTime and endTime
        // which are the audio boundaries used. Think of offsetTime like
        // a timeline bar that's in the middle of a chunk of audio. Probably
        // a more elegant way to express this, but it's a hint for the fade
        // to know if it needs to change, or if it's past or in the middle
        // of one.
        player.offsetTime = offsetTime

        // update the fade if passed in
        if let fade = fade {
            player.fade = fade
        }

        afterStart = {
            player.play(from: startingTime,
                        to: endingTime,
                        at: audioTime,
                        hostTime: nil)
        }
        engine.output = player
        duration = testDuration / rate

        AKLog("from", startingTime, "to", endingTime, "duration:", duration)

        auditioning ? auditionTest() : AKTest(md5)
    }
}

#endif
