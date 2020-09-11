// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation
import Foundation

extension AVAudioEngine {
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
    public func render(to audioFile: AVAudioFile,
                       maximumFrameCount: AVAudioFrameCount = 4_096,
                       duration: Double,
                       renderUntilSilent: Bool = false,
                       silenceThreshold: Float = 0.00005,
                       prerender: (() -> Void)? = nil,
                       progress progressHandler: ((Double) -> Void)? = nil) throws {
        guard duration >= 0 else {
            throw NSError(domain: "AVAudioEngine ext", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Seconds needs to be a positive value"])
        }

        try AKTry {
            // Engine can't be running when switching to offline render mode.
            if self.isRunning { self.stop() }
            try self.enableManualRenderingMode(.offline,
                                               format: audioFile.processingFormat,
                                               maximumFrameCount: maximumFrameCount)

            // This resets the sampleTime of offline rendering to 0.
            self.reset()
            try self.start()
        }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: manualRenderingFormat,
                                            frameCapacity: manualRenderingMaximumFrameCount) else {
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

            // 0 - 1
            var progressValue: Double = 0

            switch status {
            case .success:
                try audioFile.write(from: buffer)
                progressValue = min(Double(audioFile.framePosition) / Double(targetSamples), 1.0)
                progressHandler?(progressValue)
            case .cannotDoInCurrentContext:
                AKLog("renderToFile cannotDoInCurrentContext", type: .error)
                continue
            case .error, .insufficientDataFromInputNode:
                throw NSError(domain: "AVAudioEngine ext", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "render error"])
            @unknown default:
                AKLog("Unknown render result:", status, type: .error)
                isRendering = false
            }

            if renderUntilSilent, progressValue == 1, let data = buffer.floatChannelData {
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

        try AKTry {
            self.stop()
            self.disableManualRenderingMode()
        }
    }
}

extension AVAudioEngine {
    internal func mixerHasInputs(mixer: AVAudioMixerNode) -> Bool {
        return (0 ..< mixer.numberOfInputs).contains {
            self.inputConnectionPoint(for: mixer, inputBus: $0) != nil
        }
    }
}
