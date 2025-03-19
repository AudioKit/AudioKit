// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFAudio

@available(iOS 13.0, *)
class MatrixMixerTests: XCTestCase {
    let engine = AudioEngine()
    var mixer = MatrixMixer([ConstantGenerator(constant: 1), ConstantGenerator(constant: 2)])
    var data: AVAudioPCMBuffer!

    var output0: [Float] { data.toFloatChannelData()!.first! }
    var output1: [Float] { data.toFloatChannelData()!.last! }

    override func setUp() {
        super.setUp()
        Settings.sampleRate = 44100
        mixer.outputFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        engine.output = mixer
        data = engine.startTest(totalDuration: 1)
        mixer.unmuteAllInputsAndOutputs()
        mixer.masterVolume = 1
    }

    func testMapChannel0ToChannel0() {
        mixer.set(volume: 1, atCrosspoints: [(0, 0)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 1 })
        XCTAssertTrue(output1.allSatisfy { $0 == 0 })
    }

    func testMapChannel0ToChannel1() {
        mixer.set(volume: 1, atCrosspoints: [(0, 1)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 0 })
        XCTAssertTrue(output1.allSatisfy { $0 == 1 })
    }

    func testMapChannel2ToChannel0() {
        mixer.set(volume: 1, atCrosspoints: [(2, 0)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 2 })
        XCTAssertTrue(output1.allSatisfy { $0 == 0 })
    }

    func testMapChannel0And2ToChannel0() {
        mixer.set(volume: 1, atCrosspoints: [(0, 0)])
        mixer.set(volume: 1, atCrosspoints: [(2, 0)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 3 })
        XCTAssertTrue(output1.allSatisfy { $0 == 0 })
    }

    func testMapChannel2ToChannel0MasterVolume0() {
        mixer.masterVolume = 0
        mixer.set(volume: 1, atCrosspoints: [(2, 0)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 0 })
        XCTAssertTrue(output1.allSatisfy { $0 == 0 })
    }

    func testMapChannel2ToChannel0Channel0Output0Volume0() {
        mixer.set(volume: 0, outputChannelIndex: 0)
        mixer.set(volume: 1, atCrosspoints: [(2, 0)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 0 })
        XCTAssertTrue(output1.allSatisfy { $0 == 0 })
    }

    func testMapChannel2ToChannel0Channel0Input2Volume0() {
        mixer.set(volume: 0, inputChannelIndex: 2)
        mixer.set(volume: 1, atCrosspoints: [(2, 0)])
        data.append(engine.render(duration: 1))

        XCTAssertTrue(output0.allSatisfy { $0 == 0 })
        XCTAssertTrue(output1.allSatisfy { $0 == 0 })
    }
}
