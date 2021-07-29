// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class MixerTests: XCTestCase {
    func testSplitConnection() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let mixer1 = Mixer(player)
        let mixer2 = Mixer()
        engine.output = Mixer(mixer1, mixer2)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        mixer2.addInput(player)
        mixer2.removeInput(player)
        mixer2.addInput(player)
        testMD5(audio)
    }
}

extension MixerTests {
    /// Hack fix for issue: https://github.com/AudioKit/AudioKit/issues/2527
    func testWiringAfterEngineStart() {
        let engine = AudioEngine()
        let engineMixer = Mixer()
        engine.output = engineMixer
        try? engine.start()

        let subtreeMixer = Mixer()

        // mixer is empty so must initialize
        let mixerReset1 = engine.avEngine.initializeMixer(engineMixer.avAudioNode)
        
        engineMixer.addInput(subtreeMixer)
        
        if let mixerReset = mixerReset1 {
            engine.avEngine.disconnectNodeOutput(mixerReset)
        }

        let url = Bundle.module.url(forResource: "12345",
                                    withExtension: "wav",
                                    subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!

        // mixer is empty so must initialize
        let mixerReset2 = engine.avEngine.initializeMixer(subtreeMixer.avAudioNode)

        subtreeMixer.addInput(player)

        if let mixerReset = mixerReset2 {
            engine.avEngine.disconnectNodeOutput(mixerReset)
        }

        print(engine.connectionTreeDescription)
        player.play()

        engine.stop()
    }
}

extension AVAudioEngine {
    internal func mixerHasInputs(mixer: AVAudioMixerNode) -> Bool {
        return (0 ..< mixer.numberOfInputs).contains {
            self.inputConnectionPoint(for: mixer, inputBus: $0) != nil
        }
    }

    /// If an AVAudioMixerNode's output connection is made while engine is running, and there are no input connections
    /// on the mixer, subsequent connections made to the mixer will silently fail.  A workaround is to connect a dummy
    /// node to the mixer prior to making a connection, then removing the dummy node after the connection has been made.
    /// This is still a bug as of macOS 11.4 (2021). A place in ADD where this would happen is the Importer editor
    internal func initializeMixer(_ node: AVAudioNode) -> AVAudioNode? {
        // Only an issue if engine is running, node is a mixer, and mixer has no inputs
        guard isRunning,
              let mixer = node as? AVAudioMixerNode,
              !mixerHasInputs(mixer: mixer) else {
            return nil
        }

        let dummy = AVAudioUnitSampler()
        attach(dummy)
        connect(dummy,
                to: mixer,
                format: Settings.audioFormat)

        Log("⚠️🎚 Added dummy to mixer (\(mixer) with format", Settings.audioFormat)
        return dummy
    }
}
