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

    public init(outputBuffer: UnsafeMutablePointer<AudioBufferList>,
                outputPCMBuffer: AVAudioPCMBuffer,
                renderBlock: @escaping AURenderBlock,
                inputBlock: @escaping AURenderPullInputBlock,
                avAudioEngine: AVAudioEngine? = nil,
                inputCount: Int32,
                outputIndices: [Int]) {
        self.outputBuffer = outputBuffer
        self.outputPCMBuffer = outputPCMBuffer
        self.renderBlock = renderBlock
        self.inputBlock = inputBlock
        self.avAudioEngine = avAudioEngine
        self.inputCount = inputCount
        self.outputIndices = outputIndices
    }

    func render(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                timeStamp: UnsafePointer<AudioTimeStamp>,
                frameCount: AUAudioFrameCount,
                outputBufferList: UnsafeMutablePointer<AudioBufferList>?) {

        let out = outputBufferList ?? outputBuffer
        let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(out)

        // AUs may change the output size, so reset it.
        outputBufferListPointer[0].mDataByteSize = frameCount * UInt32(MemoryLayout<Float>.size)
        outputBufferListPointer[1].mDataByteSize = frameCount * UInt32(MemoryLayout<Float>.size)

        let data0Before = outputBufferListPointer[0].mData
        let data1Before = outputBufferListPointer[1].mData

        // Do the actual DSP.
        let status = renderBlock(actionFlags,
                                      timeStamp,
                                      frameCount,
                                      0,
                                      out,
                                      inputBlock)

        // Make sure the AU doesn't change the buffer pointers!
        assert(outputBufferListPointer[0].mData == data0Before)
        assert(outputBufferListPointer[1].mData == data1Before)

        // Propagate errors.
        if status != noErr {
            switch status {
            case kAudioUnitErr_NoConnection:
                print("got kAudioUnitErr_NoConnection")
            case kAudioUnitErr_TooManyFramesToProcess:
                print("got kAudioUnitErr_TooManyFramesToProcess")
            case AVAudioEngineManualRenderingError.notRunning.rawValue:
                print("got AVAudioEngineManualRenderingErrorNotRunning")
            case kAudio_ParamError:
                print("got kAudio_ParamError")
            default:
                print("unknown rendering error \(status)")
            }
        }
    }
}
