// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox
import Atomics

/// Information to render a single AudioUnit
public class RenderJob {
    var outputBuffer: UnsafeMutablePointer<AudioBufferList>
    var outputPCMBuffer: AVAudioPCMBuffer
    var renderBlock: AURenderBlock
    var inputBlock: AURenderPullInputBlock
    var avAudioEngine: AVAudioEngine?

    /// Number of inputs feeding this AU.
    var inputCount: Int32

    /// Indices of AUs that this one feeds.
    var outputIndices: [Int]

    public init(outputBuffer: UnsafeMutablePointer<AudioBufferList>, outputPCMBuffer: AVAudioPCMBuffer, renderBlock: @escaping AURenderBlock, inputBlock: @escaping AURenderPullInputBlock, avAudioEngine: AVAudioEngine? = nil, inputCount: Int32, outputIndices: [Int]) {
        self.outputBuffer = outputBuffer
        self.outputPCMBuffer = outputPCMBuffer
        self.renderBlock = renderBlock
        self.inputBlock = inputBlock
        self.avAudioEngine = avAudioEngine
        self.inputCount = inputCount
        self.outputIndices = outputIndices
    }
}
