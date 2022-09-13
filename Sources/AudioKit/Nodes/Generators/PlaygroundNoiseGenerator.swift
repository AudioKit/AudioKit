// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CoreAudio // for UnsafeMutableAudioBufferListPointer

/// Pure Swift Noise Generator
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public class PlaygroundNoiseGenerator: Node {
    fileprivate lazy var sourceNode = AVAudioSourceNode { [self] _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

        if self.isStarted {
            for frame in 0 ..< Int(frameCount) {
                // Get signal value for this frame at time.
                let value = self.amplitude * Float.random(in: -1 ... 1)

                // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = value
                }
            }
        } else {
            for frame in 0 ..< Int(frameCount) {
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = 0
                }
            }
        }
        return noErr
    }

    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { sourceNode }

    /// Volume usually 0-1
    public var amplitude: AUValue = 1

    /// Initialize the pure Swift noise generator, suitable for Playgrounds
    /// - Parameters:
    ///   - amplitude: Volume, usually 0-1
    public init(amplitude: AUValue = 1) {
        self.amplitude = amplitude

        stop()
    }
}
