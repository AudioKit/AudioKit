//
//  AVAudioEngine+Extensions.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/20/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension AVAudioEngine {

    /// Adding connection between nodes with default format
    open func connect(_ node1: AVAudioNode, to node2: AVAudioNode) {
        connect(node1, to: node2, format: AKManager.format)
    }

    /// Render output to an AVAudioFile for a duration.
    ///     - Parameters
    ///         - audioFile: An file initialized for writing
    ///         - duration: Duration to render, in seconds
    ///         - prerender: A closure called before rendering starts, use this to start players, set initial parameters, etc...
    ///         - progress: A closure called while rendering, use this to fetch render progress
    ///
    @available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
    public func renderToFile(_ audioFile: AVAudioFile,
                             maximumFrameCount: AVAudioFrameCount = 4_096,
                             duration: Double,
                             prerender: (() -> Void)? = nil,
                             progress: ((Double) -> Void)? = nil) throws {

        guard duration >= 0 else {
            throw NSError(domain: "AVAudioEngine ext", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Seconds needs to be a positive value"])
        }
        try AKTry {
            // Engine can't be running when switching to offline render mode.
            if self.isRunning { self.stop() }
            try self.enableManualRenderingMode(.offline, format: audioFile.processingFormat, maximumFrameCount: maximumFrameCount)

            // This resets the sampleTime of offline rendering to 0.
            self.reset()
            try self.start()
        }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: manualRenderingFormat, frameCapacity: manualRenderingMaximumFrameCount) else {
            throw NSError(domain: "AVAudioEngine ext", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Couldn't create buffer in renderToFile"])
        }

        // This is for users to prepare the nodes for playing, i.e player.play()
        prerender?()

        // Render until file contains >= target samples
        let targetSamples = AVAudioFramePosition(duration * manualRenderingFormat.sampleRate)
        while audioFile.framePosition < targetSamples {
            let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount( targetSamples - audioFile.framePosition))
            let status = try renderOffline(framesToRender, to: buffer)
            switch status {
            case .success:
                try audioFile.write(from: buffer)
                progress?(min(Double(audioFile.framePosition) / Double(targetSamples), 1.0))
            case .cannotDoInCurrentContext:
                AKLog("renderToFile cannotDoInCurrentContext")
                continue
            case .error, .insufficientDataFromInputNode:
                throw NSError(domain: "AVAudioEngine ext", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "renderToFile render error"])
            @unknown default:
                fatalError("Unknown render result")
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
        return (0..<mixer.numberOfInputs).contains {
            self.inputConnectionPoint(for: mixer, inputBus: $0) != nil
        }
    }
}
