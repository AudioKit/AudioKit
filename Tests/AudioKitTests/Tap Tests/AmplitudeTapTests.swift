// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFAudio

class AmplitudeTapTests: XCTestCase {

    func testTapDoesntDeadlockOnStop() throws {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player
        let tap = AmplitudeTap(player, callbackQueue: .main)

        _ = engine.startTest(totalDuration: 1)
        tap.start()
        _ = engine.render(duration: 1)
        tap.stop()

        XCTAssertFalse(tap.isStarted)
    }

    func testTapDoesntDeadlockOnStopWhenRunningOnAnotherQueue() throws {
        let queue = DispatchQueue(label: "test")
        let expectation = self.expectation(description: "")
        queue.async {
            let engine = AudioEngine()
            let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
            let player = AudioPlayer(url: url)!
            engine.output = player
            let tap = AmplitudeTap(player, callbackQueue: queue)

            _ = engine.startTest(totalDuration: 1)
            tap.start()
            _ = engine.render(duration: 1)
            tap.stop()
            XCTAssertFalse(tap.isStarted)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testDoesntCrashForMoreThenTwoChannels() {
        let channelCount: UInt32 = 4
        let channelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_DiscreteInOrder | channelCount)!
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channelLayout: channelLayout)

        let reverb = CustomFormatReverb(AudioPlayer(), outputFormat: format)
        let tap = AmplitudeTap(reverb, callbackQueue: .main)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1)!
        for channel in 0...Int(channelCount - 1) {
            buffer.floatChannelData?[channel][0] = 0.0
        }
        tap.doHandleTapBlock(buffer: buffer, at: .now())
    }

    func testStopResetsAllToZero() {
        let channelCount: UInt32 = 4
        let channelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_DiscreteInOrder | channelCount)!
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channelLayout: channelLayout)

        let reverb = CustomFormatReverb(AudioPlayer(), outputFormat: format)
        let tap = AmplitudeTap(reverb, callbackQueue: .main)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1)!
        buffer.frameLength = 1
        for channel in 0...Int(channelCount - 1) {
            buffer.floatChannelData?[channel][0] = 1.0
        }
        tap.doHandleTapBlock(buffer: buffer, at: .now())
        tap.stop()
        XCTAssertEqual(tap.amplitude, 0)
    }

    func testAmplitudeIsAverageOfAllChannels() {
        let channelCount: UInt32 = 4
        let channelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_DiscreteInOrder | channelCount)!
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channelLayout: channelLayout)

        let reverb = CustomFormatReverb(AudioPlayer(), outputFormat: format)
        let tap = AmplitudeTap(reverb, callbackQueue: .main)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1)!
        buffer.frameLength = 1
        for channel in 0...Int(channelCount - 1) {
            buffer.floatChannelData?[channel][0] = 1.0
        }
        tap.doHandleTapBlock(buffer: buffer, at: .now())
        XCTAssertEqual(tap.amplitude, 1)
    }

    func check(values: [Float], known: [Float]) {
        if values.count >= known.count {
            for i in 0..<known.count {
                XCTAssertEqual(values[i], 0.579 * known[i], accuracy: 0.03)
            }
        }
    }

    @available(iOS 13.0, *)
    func testDefault() {

        let engine = AudioEngine()

        var detectedAmplitudes: [Float] = []
        let targetAmplitudes: [Float] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

        let noise = PlaygroundNoiseGenerator(amplitude: 0.0)
        engine.output = noise
        noise.start()

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(noise, callbackQueue: .main) { amp in
            if abs(amp - (detectedAmplitudes.last ?? 0.0)) > 0.05 {
                detectedAmplitudes.append(amp)
                if detectedAmplitudes.count == 10 {
                    expect.fulfill()
                }
            }

        }
        tap.start()

        let audio = engine.startTest(totalDuration: 10.0)
        for amplitude in targetAmplitudes {
            noise.amplitude = amplitude
            audio.append(engine.render(duration: 1.0))
        }
        wait(for: [expect], timeout: 10.0)

        check(values: detectedAmplitudes, known: targetAmplitudes)

    }


}
