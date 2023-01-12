// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

/// New audio engine to mostly replace AVAudioEngine. Eventually we will completely replace AVAudioEngine.
///
/// See https://github.com/AudioKit/AudioKit/issues/2804
public class Engine {
    /// Internal AVAudioEngine
    private let avEngine = AVAudioEngine()

    public var output: Node? {
        didSet {
            engineAU?.output = output
        }
    }

    public var engineAU: EngineAudioUnit?
    var avAudioUnit: AVAudioUnit?

    // maximum number of frames the engine will be asked to render in any single render call
    let maximumFrameCount: AVAudioFrameCount = 1024

    public init() {
        let componentDescription = AudioComponentDescription(effect: "akau")

        AUAudioUnit.registerSubclass(EngineAudioUnit.self,
                                     as: componentDescription,
                                     name: "engine AU",
                                     version: .max)

        AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, _ in
            guard let au = avAudioUnit else { fatalError("Unable to instantiate EngineAudioUnit") }

            self.engineAU = au.auAudioUnit as? EngineAudioUnit

            self.avEngine.attach(au)
            self.avEngine.connect(self.avEngine.inputNode, to: au, format: nil)
            self.avEngine.connect(au, to: self.avEngine.mainMixerNode, format: nil)
        }
    }

    /// Start the engine
    public func start() throws {
        try avEngine.start()
    }

    /// Stop the engine
    public func stop() {
        avEngine.stop()
    }

    /// Pause the engine
    public func pause() {
        avEngine.pause()
    }

    /// Start testing for a specified total duration
    /// - Parameter duration: Total duration of the entire test
    /// - Returns: A buffer which you can append to
    public func startTest(totalDuration duration: Double, sampleRate: Double = 44100) -> AVAudioPCMBuffer {
        let samples = Int(duration * sampleRate)

        do {
            avEngine.reset()
            try avEngine.enableManualRenderingMode(.offline,
                                                   format: Settings.audioFormat,
                                                   maximumFrameCount: maximumFrameCount)
            try start()
        } catch let err {
            Log("🛑 Start Test Error: \(err)")
        }

        return AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(samples)
        )!
    }

    /// Render audio for a specific duration
    /// - Parameter duration: Length of time to render for
    /// - Returns: Buffer of rendered audio
    public func render(duration: Double, sampleRate: Double = 44100) -> AVAudioPCMBuffer {
        let sampleCount = Int(duration * sampleRate)
        let startSampleCount = Int(avEngine.manualRenderingSampleTime)

        let buffer = AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(sampleCount)
        )!

        let tempBuffer = AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(maximumFrameCount)
        )!

        do {
            while avEngine.manualRenderingSampleTime < sampleCount + startSampleCount {
                let currentSampleCount = Int(avEngine.manualRenderingSampleTime)
                let framesToRender = min(UInt32(sampleCount + startSampleCount - currentSampleCount), maximumFrameCount)
                try avEngine.renderOffline(AVAudioFrameCount(framesToRender), to: tempBuffer)
                buffer.append(tempBuffer)
            }
        } catch let err {
            Log("🛑 Could not render offline \(err)")
        }
        return buffer
    }
}
