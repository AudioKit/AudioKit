// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class EngineTests: XCTestCase {
    func testBasic() throws {
        let engine = Engine()

        let osc = Oscillator()

        engine.output = osc

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testEffect() throws {
        let engine = Engine()

        let osc = Oscillator()
        let fx = Distortion(osc)

        engine.output = fx

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testTwoEffects() throws {
        let engine = Engine()

        let osc = Oscillator()
        let dist = Distortion(osc)
        let dyn = PeakLimiter(dist)

        engine.output = dyn

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    /// Test changing the output chain on the fly.
    func testDynamicChange() throws {
        let engine = Engine()

        let osc = Oscillator()
        let dist = Distortion(osc)

        engine.output = osc

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        engine.output = dist

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixer() throws {
        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        engine.output = mix

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume() throws {
        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        mix.volume = 0.02

        engine.output = mix

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerDynamic() throws {
        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1])

        engine.output = mix

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        mix.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume2() throws {
        let avAudioEngineMixerMD5s: [String] = [
            // Apple                            // Intel
            "07a5ba764493617dcaa54d16e8cbec99", "4fc54784f2f7bcf2d51ad3c42a6639c2",
            "1366766f7dfa7282c0f15150c8ad09f7", "2ab46479ab6506bae3014d23be5e0dce",
            "34d94eb74e7a6baff6b3f01615516824", "6ea69742d46f2d0d4d667b3e9b3baef4",
            "1b6fcf41250ee6acef62fd8aa9653159", "71944222e8b87cb9d9bbbb8461a26772",
            "96f75d59420c90eefa2a9f953902f358", "434ec09c1e71d0bdef1a91c92a0d2c30",
            "5e2d75d048f097335e87c5ab3645078e", "18de289a354bd1ef3d7b108328f3cc60",
        ]

        for volume in [0.0, 0.1, 0.5, 0.8, 1.0, 2.0] {
            let engine = Engine()
            let osc = Oscillator()
            let mix = Mixer(osc)
            mix.volume = AUValue(volume)
            engine.output = mix
            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            XCTAssertTrue(avAudioEngineMixerMD5s.contains(audio.md5))
        }
    }

    func testMixerPan() throws {
        let duration = 1.0

        let avAudioEngineMixerMD5s: [String] = [
            // Apple                            // Intel
            "71957476da05b8e62115113c419625cb", "412baf8dcec60f2825b608f3b493440e",
            "4988fa152c867d15c8b263c4b9ae66aa", "0ec52383c98b02a23a6b194a5ffc3166",
            "71a9223cde9f0288fe339bd3e3ba57e3", "b4274749a5d4370ea3d4cd1e69e9a2a4",
            "32a97296e60a398a8b6f5533817e7e69", "01c21afad50c08f7ff411b431e1dae5b",
            "5f6a773a46341897356a5997dd73245b", "92177ede4f8265a9e4221c890e08e458",
            "b18e555120c1e7fa2103e55cb718d42d", "22a130e99a4a75113f2a816a4644a7b1",
            "cfc283772998074a5b0e38fff916a87a", "c62c7e285d8552eac689ce193a300ed1",
        ]

        for pan in [-0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75] {
            let engine = Engine()
            let oscL = Oscillator()
            let oscR = Oscillator()
            oscR.frequency = 500
            let mixL = Mixer(oscL)
            let mixR = Mixer(oscR)
            mixL.pan = -1.0
            mixR.pan = 1.0
            let mixer = Mixer(mixL, mixR)
            mixer.pan = AUValue(pan)
            engine.output = mixer
            let audio = engine.startTest(totalDuration: duration)
            audio.append(engine.render(duration: duration))

            XCTAssertTrue(avAudioEngineMixerMD5s.contains(audio.md5))
        }
    }

    /// Test some number of changes so schedules are released.
    func testMultipleChanges() throws {
        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()

        osc1.frequency = 880

        engine.output = osc1

        let audio = engine.startTest(totalDuration: 10.0)

        for i in 0 ..< 10 {
            audio.append(engine.render(duration: 1.0))
            engine.output = (i % 2 == 1) ? osc1 : osc2
        }

        testMD5(audio)
    }

    /// Lists all AUs on the system so we can identify which Apple ones are available.
    func testListAUs() throws {
        let auManager = AVAudioUnitComponentManager.shared()

        // Get an array of all available Audio Units
        let audioUnits = auManager.components(passingTest: { _, _ in true })

        for audioUnit in audioUnits {
            // Get the audio unit's name
            let name = audioUnit.name

            print("Audio Unit: \(name)")
        }
    }

    func testOscillator() {
        let engine = Engine()
        let osc = Oscillator()
        engine.output = osc
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSysexEncoding() {
        let value = 42
        let sysex = encodeSysex(value)

        XCTAssertEqual(sysex.count, 19)

        var decoded = 0
        decodeSysex(sysex, count: 19, &decoded)

        XCTAssertEqual(decoded, 42)
    }

    func testManyOscillatorsPerf() throws {
        let engine = Engine()

        let mixer = Mixer()

        for _ in 0 ..< 20 {
            let osc = Oscillator()
            mixer.addInput(osc)
        }

        mixer.volume = 0.001
        engine.output = mixer

        measure {
            let audio = engine.startTest(totalDuration: 2.0)
            audio.append(engine.render(duration: 2.0))
        }
    }
}
