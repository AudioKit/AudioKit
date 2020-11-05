// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class EngineTests: XCTestCase {
    // Setting Settings.audioFormat will change subsequent node connections
    // from 44_100 which the MD5's were created with
    func testNodeSampleRateIsSet() {
        let previousFormat = Settings.audioFormat

        let chosenRate: Double = 48_000
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: chosenRate, channels: 2) else {
            Log("Failed to create format")
            return
        }

        if audioFormat != Settings.audioFormat {
            Log("Changing audioFormat to", audioFormat)
        }
        Settings.audioFormat = audioFormat

        let engine = AudioEngine()
        let oscillator = Oscillator()
        let mixer = Mixer(oscillator)

        // assign input and engine references
        engine.output = mixer

        let mixerSampleRate = mixer.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate
        let engineSampleRate = engine.avEngine.outputNode.outputFormat(forBus: 0).sampleRate
        let engineDynamicMixerSampleRate = engine.mainMixerNode?.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate
        let oscSampleRate = oscillator.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate

        XCTAssertTrue(mixerSampleRate == chosenRate,
                      "mixerSampleRate \(mixerSampleRate), actual rate \(chosenRate)")

        // the mixer should be the mainMixerNode in this test
        XCTAssertTrue(engineDynamicMixerSampleRate == chosenRate && mixer === engine.mainMixerNode,
                      "engineDynamicMixerSampleRate \(mixerSampleRate), actual rate \(chosenRate)")

        XCTAssertTrue(oscSampleRate == chosenRate,
                      "oscSampleRate \(oscSampleRate), actual rate \(chosenRate)")
        XCTAssertTrue(engineSampleRate == chosenRate,
                      "engineSampleRate \(engineSampleRate), actual rate \(chosenRate)")

        Log(engine.avEngine.description)

        // restore
        Settings.audioFormat = previousFormat
    }

    func testEngineMainMixerOverride() {
        let engine = AudioEngine()
        let oscillator = Oscillator()
        let mixer = Mixer(oscillator)
        engine.output = mixer
        XCTAssertTrue(engine.mainMixerNode === mixer, "created mixer should be adopted as the engine's main mixer")
    }

    func testEngineMainMixerCreated() {
        let engine = AudioEngine()
        let oscillator = Oscillator()
        engine.output = oscillator
        XCTAssertNotNil(engine.mainMixerNode, "created mixer is nil")
    }

    func testChangeEngineOutputWhileRunning() {
        let engine = AudioEngine()
        let oscillator = Oscillator()
        oscillator.frequency = 220
        oscillator.amplitude = 0.1
        let oscillator2 = Oscillator()
        oscillator2.frequency = 440
        oscillator2.amplitude = 0.1
        engine.output = oscillator

        do {
            try engine.start()
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed to start engine")
        }

        XCTAssertTrue(engine.avEngine.isRunning, "engine isn't running")
        oscillator.start()

        // sleep(1) // for simple realtime check

        // change the output - will stop the engine
        engine.output = oscillator2

        // is it started again
        XCTAssertTrue(engine.avEngine.isRunning)

        oscillator2.start()

        // sleep(1) // for simple realtime check

        engine.stop()
    }
}
