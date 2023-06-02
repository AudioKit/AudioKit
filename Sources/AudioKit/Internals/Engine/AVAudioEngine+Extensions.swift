// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation
import Foundation

// TODO: add unit test.

public extension AVAudioEngine {
    /// Render output to an AVAudioFile for a duration.
    ///     - Parameters
    ///         - audioFile: A file initialized for writing
    ///         - duration: Duration to render, in seconds
    ///         - renderUntilSilent: After completing rendering to the passed in duration, wait for silence. Useful
    ///         for capturing effects tails.
    ///         - silenceThreshold: Threshold value to check for silence. Default is 0.00005.
    ///         - prerender: Closure called before rendering starts, used to start players, set initial parameters, etc.
    ///         - progress: Closure called while rendering, use this to fetch render progress
    ///
    @available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
    func render(to audioFile: AVAudioFile,
                maximumFrameCount: AVAudioFrameCount = 4096,
                duration: Double,
                renderUntilSilent: Bool = false,
                silenceThreshold: Float = 0.00005,
                prerender: (() -> Void)? = nil,
                progress progressHandler: ((Double) -> Void)? = nil) throws
    {
        guard duration >= 0 else {
            throw NSError(domain: "AVAudioEngine ext", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Seconds needs to be a positive value"])
        }

        // Engine can't be running when switching to offline render mode.
        if isRunning { stop() }
        try enableManualRenderingMode(.offline,
                                      format: audioFile.processingFormat,
                                      maximumFrameCount: maximumFrameCount)

        // This resets the sampleTime of offline rendering to 0.
        reset()
        try start()

        guard let buffer = AVAudioPCMBuffer(pcmFormat: manualRenderingFormat,
                                            frameCapacity: manualRenderingMaximumFrameCount)
        else {
            throw NSError(domain: "AVAudioEngine ext", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Couldn't create buffer in renderToFile"])
        }

        // This is for users to prepare the nodes for playing, i.e player.play()
        prerender?()

        // Render until file contains >= target samples
        let targetSamples = AVAudioFramePosition(duration * manualRenderingFormat.sampleRate)
        let channelCount = Int(buffer.format.channelCount)
        var zeroCount = 0
        var isRendering = true

        while isRendering {
            if !renderUntilSilent, audioFile.framePosition >= targetSamples {
                break
            }
            let framesToRender = renderUntilSilent ? manualRenderingMaximumFrameCount
                : min(buffer.frameCapacity, AVAudioFrameCount(targetSamples - audioFile.framePosition))

            let status = try renderOffline(framesToRender, to: buffer)

            // Progress in the range of starting (0) - finished (1)
            var progress: Double = 0

            switch status {
            case .success:
                try audioFile.write(from: buffer)
                progress = min(Double(audioFile.framePosition) / Double(targetSamples), 1.0)
                progressHandler?(progress)
            case .cannotDoInCurrentContext:
                Log("renderToFile cannotDoInCurrentContext", type: .error)
                continue
            case .error, .insufficientDataFromInputNode:
                throw NSError(domain: "AVAudioEngine ext", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "render error"])
            @unknown default:
                Log("Unknown render result:", status, type: .error)
                isRendering = false
            }

            if renderUntilSilent, progress == 1, let data = buffer.floatChannelData {
                var rms: Float = 0.0
                for i in 0 ..< channelCount {
                    var channelRms: Float = 0.0
                    vDSP_rmsqv(data[i], 1, &channelRms, vDSP_Length(buffer.frameLength))
                    rms += abs(channelRms)
                }
                let value = (rms / Float(channelCount))

                if value < silenceThreshold {
                    zeroCount += 1
                    // check for consecutive buffers of below threshold, then assume it's silent
                    if zeroCount > 2 {
                        isRendering = false
                    }
                } else {
                    // Resetting consecutive threshold check due to positive value
                    zeroCount = 0
                }
            }
        }

        stop()
        disableManualRenderingMode()
    }
}

extension AVAudioEngine {
    func mixerHasInputs(mixer: AVAudioMixerNode) -> Bool {
        return (0 ..< mixer.numberOfInputs).contains {
            self.inputConnectionPoint(for: mixer, inputBus: $0) != nil
        }
    }

    /// If an AVAudioMixerNode's output connection is made while engine is running, and there are no input connections
    /// on the mixer, subsequent connections made to the mixer will silently fail.  A workaround is to connect a dummy
    /// node to the mixer prior to making a connection, then removing the dummy node after the connection has been made.
    /// This is still a bug as of macOS 11.4 (2021). A place in ADD where this would happen is the Importer editor
    /// http://openradar.appspot.com/radar?id=5588189343383552
    func initializeMixer(_ node: AVAudioNode) -> AVAudioNode? {
        // Only an issue if engine is running, node is a mixer, and mixer has no inputs
        guard isRunning,
              let mixer = node as? AVAudioMixerNode,
              !mixerHasInputs(mixer: mixer)
        else {
            return nil
        }

        let dummy = EngineResetNode()
        attach(dummy)
        connect(dummy,
                to: mixer,
                format: Settings.audioFormat)

        Log("⚠️🎚 Added dummy to mixer (\(mixer) with format", Settings.audioFormat)
        return dummy
    }

    // Create a new type so we're sure what it is if instances are leaked
    private class EngineResetNode: AVAudioUnitSampler {}
}
