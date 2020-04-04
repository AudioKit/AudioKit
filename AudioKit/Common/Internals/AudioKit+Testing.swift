//
//  AudioKit+Testing.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/20/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension AudioKit {

    // MARK: - Testing

    /// Testing AKNode
    @objc public static var tester: AKTester?

    /// Test the output of a given node
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///   - afterStart: Closure to execute at the beginning of the test
    ///
    @objc public static func test(node: AKNode, duration: Double, afterStart: () -> Void = {}) throws {
        #if swift(>=3.2)
        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            let samples = Int(duration * AKSettings.sampleRate)

            tester = AKTester(node, samples: samples)
            output = tester

            // maximum number of frames the engine will be asked to render in any single render call
            let maximumFrameCount: AVAudioFrameCount = 4_096
            try AKTry {
                engine.reset()
                try engine.enableManualRenderingMode(.offline, format: AKSettings.audioFormat, maximumFrameCount: maximumFrameCount)
                try engine.start()
            }

            afterStart()
            tester?.play()

            let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                                            frameCapacity: engine.manualRenderingMaximumFrameCount)!

            while engine.manualRenderingSampleTime < samples {
                let framesToRender = buffer.frameCapacity
                let status = try engine.renderOffline(framesToRender, to: buffer)
                switch status {
                case .success:
                    // data rendered successfully
                    break

                case .insufficientDataFromInputNode:
                    // applicable only if using the input node as one of the sources
                    break

                case .cannotDoInCurrentContext:
                    // engine could not render in the current render call, retry in next iteration
                    break

                case .error:
                    // error occurred while rendering
                    fatalError("render failed")
                @unknown default:
                    fatalError("Unknown render result")
                }
            }
            tester?.stop()
        }
        #endif
    }

    /// Audition the test to hear what it sounds like
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///
    @objc public static func auditionTest(node: AKNode, duration: Double) throws {
        output = node
        try start()
        if let playableNode = node as? AKToggleable {
            playableNode.play()
        }
        usleep(UInt32(duration * 1_000_000))
        try stop()
        try start()
    }
}
