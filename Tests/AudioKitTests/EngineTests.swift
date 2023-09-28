// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class EngineTests: XCTestCase {
    // Changing Settings.audioFormat will change subsequent node connections
    // from 44_100 which the MD5's were created with so be sure to change it back at the end of a test

    func testEngineSampleRateGraphConsistency() {
        let previousFormat = Settings.audioFormat

        let newRate: Double = 48000
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
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        let mixer = Mixer(input)

        // assign input and engine references
        engine.output = mixer

        let mixerSampleRate = mixer.avAudioNode.outputFormat(forBus: 0).sampleRate
        let mainMixerNodeSampleRate = engine.mainMixerNode?.avAudioNode.outputFormat(forBus: 0).sampleRate
        let inputSampleRate = input.avAudioNode.outputFormat(forBus: 0).sampleRate

        XCTAssertTrue(mixerSampleRate == newRate,
                      "mixerSampleRate is \(mixerSampleRate), requested rate was \(newRate)")

        XCTAssertTrue(mainMixerNodeSampleRate == newRate,
                      "mainMixerNodeSampleRate is \(mixerSampleRate), requested rate was \(newRate)")

        XCTAssertTrue(inputSampleRate == newRate,
                      "oscSampleRate is \(inputSampleRate), requested rate was \(newRate)")

        Log(engine.avEngine.description)

        // restore
        Settings.audioFormat = previousFormat
    }

    func testEngineSampleRateChanged() {
        let previousFormat = Settings.audioFormat

        guard let audioFormat441k = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2) else {
            XCTFail("Failed to create format at 44.1k")
            return
        }
        guard let audioFormat48k = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 2) else {
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
        let mainMixerNodeSampleRate1 = mainMixerNode1.avAudioNode.outputFormat(forBus: 0).sampleRate
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
        let mainMixerNodeSampleRate2 = mainMixerNode2.avAudioNode.outputFormat(forBus: 0).sampleRate
        XCTAssertTrue(mainMixerNodeSampleRate2 == audioFormat48k.sampleRate,
                      "mainMixerNodeSampleRate2 is \(mainMixerNodeSampleRate2), requested rate was \(audioFormat48k.sampleRate)")

        Log("48000", engine.avEngine.description)

        // restore
        Log("Restoring global sample rate to", previousFormat.sampleRate)
        Settings.audioFormat = previousFormat
    }

    func testEngineMainMixerCreated() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        engine.output = input

        guard let mainMixerNode = engine.mainMixerNode else {
            XCTFail("mainMixerNode wasn't created")
            return
        }
        let isConnected = mainMixerNode.hasInput(input)

        XCTAssertTrue(isConnected, "AudioPlayer isn't in the mainMixerNode's inputs")
    }

    /*
    func testEngineSwitchOutputWhileRunning() {
        let engine = AudioEngine()
        let url1 = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input1 = AudioPlayer(url: url1)!
        let url2 = Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
        let input2 = AudioPlayer(url: url2)!
        engine.output = input1

        do {
            try engine.start()
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed to start engine")
        }

        XCTAssertTrue(engine.avEngine.isRunning, "engine isn't running")
        input1.start()

        // sleep(1) // for simple realtime check

        // change the output - will stop the engine
        engine.output = input2

        // is it started again?
        XCTAssertTrue(engine.avEngine.isRunning)

        input2.start()

        // sleep(1) // for simple realtime check

        engine.stop()
    }
 */

    func testConnectionTreeDescriptionForNilMainMixerNode() {
        let engine = AudioEngine()
        XCTAssertEqual(engine.connectionTreeDescription, "\(connectionTreeLinePrefix)mainMixerNode is nil")
    }

    func testConnectionTreeDescriptionForSingleNodeAdded() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        engine.output = input
        XCTAssertEqual(engine.connectionTreeDescription,
                       """
                       \(connectionTreeLinePrefix)↳Mixer("AudioKit Engine Mixer")
                       \(connectionTreeLinePrefix) ↳AudioPlayer
                       """)
    }

    func testConnectionTreeDescriptionForMixerWithName() {
        let engine = AudioEngine()
        let mixerName = "MixerNameFoo"
        let mixerWithName = Mixer(name: mixerName)
        engine.output = mixerWithName
        XCTAssertEqual(engine.connectionTreeDescription,
                       """
                       \(connectionTreeLinePrefix)↳Mixer("AudioKit Engine Mixer")
                       \(connectionTreeLinePrefix) ↳Mixer("\(mixerName)")
                       """)
    }

    func testConnectionTreeDescriptionForMixerWithoutName() {
        let engine = AudioEngine()
        let mixerWithoutName = Mixer()
        engine.output = mixerWithoutName
        let addressOfMixerWithoutName = MemoryAddress(of: mixerWithoutName)
        XCTAssertEqual(engine.connectionTreeDescription,
                       """
                       \(connectionTreeLinePrefix)↳Mixer("AudioKit Engine Mixer")
                       \(connectionTreeLinePrefix) ↳Mixer("\(addressOfMixerWithoutName)")
                       """)
    }

    #if os(macOS)
    func testAudioDevices() {
        XCTAssert(AudioEngine.devices.count > 0)
    }
    #endif

    func testOutputDevices() {
        XCTAssert(AudioEngine.outputDevices.count > 0)
    }

    func testInputDevices() {
        XCTAssert(AudioEngine.inputDevices.count > 0)
    }

    func testFindAudioUnit() {
        let engine = AudioEngine()
        let delayAVAudioUnit = engine.findAudioUnit(named: "AUDelay")
        XCTAssertNotNil(delayAVAudioUnit)
        let unknownAVAudioUnit = engine.findAudioUnit(named: "su·per·ca·li·fra·gil·is·tic·ex·pi·a·li·do·cious")
        XCTAssertNil(unknownAVAudioUnit)
    }
}
