// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox

public struct RenderInfo {
    var outputBuffer: UnsafeMutablePointer<AudioBufferList>
    var outputPCMBuffer: AVAudioPCMBuffer
    var renderBlock: AURenderBlock
    var inputBlock: AURenderPullInputBlock
    var avAudioEngine: AVAudioEngine?

    /// Number of inputs feeding this AU.
    var inputCount: Int32

    /// Number of inputs already executed during processing.
    ///
    /// When this reaches zero we are ready to go.
    var finishedInputs: Int32 = 0

    /// Indices of AUs that this one feeds.
    var outputIndices: [Int]
}

/// Information about what the engine needs to run on the audio thread.
public class AudioProgram {

    /// List of information about AudioUnits we're executing.
    public var infos: [RenderInfo] = []

    /// Nodes that we start processing first.
    var generatorIndices: [Int]

    /// How many AUs are remain to be run?
    var remaining: Int32 = 0

    init(infos: [RenderInfo], generatorIndices: [Int]) {
        self.infos = infos
        self.generatorIndices = generatorIndices
    }

    /// Called before we wake the workers.
    func prepare() {
        for i in infos.indices {
            infos[i].finishedInputs = 0
        }
        remaining = Int32(infos.count)
    }

    func run(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             timeStamp: UnsafePointer<AudioTimeStamp>,
             frameCount: AUAudioFrameCount,
             outputBufferList: UnsafeMutablePointer<AudioBufferList>,
             runQueue: AtomicList) {

        while remaining > 0 {

            // Pop an index off our queue.
            if let index = runQueue.pop() {

                // Execute index.

                let info = infos[index]
                let out = index == infos.count-1 ? outputBufferList : info.outputBuffer

                let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(out)

                // AUs may change the output size, so reset it.
                outputBufferListPointer[0].mDataByteSize = frameCount * UInt32(MemoryLayout<Float>.size)
                outputBufferListPointer[1].mDataByteSize = frameCount * UInt32(MemoryLayout<Float>.size)

                let data0Before = outputBufferListPointer[0].mData
                let data1Before = outputBufferListPointer[1].mData

                // Do the actual DSP.
                let status = info.renderBlock(actionFlags,
                                              timeStamp,
                                              frameCount,
                                              0,
                                              out,
                                              info.inputBlock)

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

                // Increment outputs.
                for outputIndex in infos[index].outputIndices {
                    if OSAtomicIncrement32(&infos[outputIndex].finishedInputs) == infos[outputIndex].inputCount {

                        runQueue.push(outputIndex)
                    }
                }

                OSAtomicDecrement32(&remaining)
            }
        }
    }
}
