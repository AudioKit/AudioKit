// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import CAudioKit
import XCTest

// TODO: Needs engine inputNode tests

class EngineTests: XCTestCase {
    // Changing Settings.audioFormat will change subsequent node connections
    // from 44_100 which the MD5's were created with so be sure to change it back at the end of a test

    func testEngineSampleRateGraphConsistency() {
        let previousFormat = Settings.audioFormat

        let newRate: Double = 48_000
        guard let newAudioFormat = AVAudioFormat(standardFormatWithSampleRate: newRate,
                                                 channels: 2) else {
            XCTFail("Failed to create format at \(newRate)")
            return
        }

        if newAudioFormat != Settings.audioFormat {
            Log("Changing audioFormat to", newAudioFormat)
            Settings.audioFormat = newAudioFormat
        }

        let engine = AudioEngine()
        let oscillator = Oscillator()
        let mixer = Mixer(oscillator)

        // assign input and engine references
        engine.output = mixer

        let mixerSampleRate = mixer.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate
        let mainMixerNodeSampleRate = engine.mainMixerNode?.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate
        let oscSampleRate = oscillator.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate

        XCTAssertTrue(mixerSampleRate == newRate,
                      "mixerSampleRate is \(mixerSampleRate), requested rate was \(newRate)")

        XCTAssertTrue(mainMixerNodeSampleRate == newRate,
                      "mainMixerNodeSampleRate is \(mixerSampleRate), requested rate was \(newRate)")

        XCTAssertTrue(oscSampleRate == newRate,
                      "oscSampleRate is \(oscSampleRate), requested rate was \(newRate)")

        Log(engine.avEngine.description)

        // restore
        Settings.audioFormat = previousFormat
    }

    func testEngineSampleRateChanged() {
        let previousFormat = Settings.audioFormat

        guard let audioFormat441k = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2) else {
            XCTFail("Failed to create format at 44.1k")
            return
        }
        guard let audioFormat48k = AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2) else {
            XCTFail("Failed to create format at 48k")
            return
        }

        Settings.audioFormat = audioFormat441k
        let engine = AudioEngine()
        let node1 = Mixer()
        engine.output = node1

        guard let mainMixerNode1 = engine.mainMixerNode else {
            XCTFail("mainMixerNode1 wasn't created")
            return
        }
        let mainMixerNodeSampleRate1 = mainMixerNode1.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate
        XCTAssertTrue(mainMixerNodeSampleRate1 == audioFormat441k.sampleRate,
                      "mainMixerNodeSampleRate is \(mainMixerNodeSampleRate1), requested rate was \(audioFormat441k.sampleRate)")

        Log("44100", engine.avEngine.description)

        Settings.audioFormat = audioFormat48k
        let node2 = Mixer()
        engine.output = node2

        guard let mainMixerNode2 = engine.mainMixerNode else {
            XCTFail("mainMixerNode2 wasn't created")
            return
        }
        let mainMixerNodeSampleRate2 = mainMixerNode2.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate
        XCTAssertTrue(mainMixerNodeSampleRate2 == audioFormat48k.sampleRate,
                      "mainMixerNodeSampleRate2 is \(mainMixerNodeSampleRate2), requested rate was \(audioFormat48k.sampleRate)")

        Log("48000", engine.avEngine.description)

        // restore
        Log("Restoring global sample rate to", previousFormat.sampleRate)
        Settings.audioFormat = previousFormat
    }

    func testEngineMainMixerCreated() {
        let engine = AudioEngine()
        let oscillator = Oscillator()
        engine.output = oscillator

        guard let mainMixerNode = engine.mainMixerNode else {
            XCTFail("mainMixerNode wasn't created")
            return
        }
        let isConnected = mainMixerNode.hasInput(oscillator)

        XCTAssertTrue(isConnected, "Oscillator isn't in the mainMixerNode's inputs")
    }

    func testEngineSwitchOutputWhileRunning() {
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

        // is it started again?
        XCTAssertTrue(engine.avEngine.isRunning)

        oscillator2.start()

        // sleep(1) // for simple realtime check

        engine.stop()
    }

    func testConnectionTreeDescriptionForNilMainMixerNode() {
        let engine = AudioEngine()
        XCTAssertEqual(engine.connectionTreeDescription, "\(Node.connectionTreeLinePrefix)mainMixerNode is nil")
    }

    func testConnectionTreeDescriptionForSingleNodeAdded() {
        let engine = AudioEngine()
        let oscillator = Oscillator()
        engine.output = oscillator
        XCTAssertEqual(engine.connectionTreeDescription,
        """
        \(Node.connectionTreeLinePrefix)↳Mixer("\(MemoryAddress(of: engine.mainMixerNode!).description)")
        \(Node.connectionTreeLinePrefix) ↳Oscillator
        """)
    }

    func testConnectionTreeDescriptionForMixerWithName() {
        let engine = AudioEngine()
        let mixerName = "MixerNameFoo"
        let mixerWithName = Mixer(name: mixerName)
        engine.output = mixerWithName
        XCTAssertEqual(engine.connectionTreeDescription,
        """
        \(Node.connectionTreeLinePrefix)↳Mixer("\(MemoryAddress(of: engine.mainMixerNode!).description)")
        \(Node.connectionTreeLinePrefix) ↳Mixer("\(mixerName)")
        """)
    }
}
