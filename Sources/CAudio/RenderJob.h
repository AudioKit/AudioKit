#include <vector>
#include <functional>
#include <atomic>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include "SynchronizedAudioBufferList.h"

//// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

typedef int RenderJobIndex;

namespace AudioKit {

class RenderJob {
private:
    /// Buffer we're writing to, unless overridden by buffer passed to render.
    SynrchonizedAudioBufferList2 *outputBuffer;
    
    /// Block called to render.
    std::function<AUAudioUnitStatus(AudioUnitRenderActionFlags*, const AudioTimeStamp*, AUAudioFrameCount, NSInteger, AudioBufferList*)> renderBlock;

    /// Input block passed to the renderBlock. We don't chain AUs recursively.
    std::function<AUAudioUnitStatus(AudioUnitRenderActionFlags*, const AudioTimeStamp*, AUAudioFrameCount, NSInteger, AudioBufferList*)> inputBlock;

    /// Indices of jobs that this one feeds.
    std::vector<int> outputIndices;

    /// Indices of jobs feeding this one
    std::vector<int> inputIndices;

public:
    RenderJob(SynrchonizedAudioBufferList2* outputBuffer,
              std::function<AUAudioUnitStatus(AudioUnitRenderActionFlags*, const AudioTimeStamp*, AUAudioFrameCount, NSInteger, AudioBufferList*)> renderBlock,
              std::function<AUAudioUnitStatus(AudioUnitRenderActionFlags*, const AudioTimeStamp*, AUAudioFrameCount, NSInteger, AudioBufferList*)> inputBlock,
              std::vector<int> inputIndices)
        : outputBuffer(outputBuffer), renderBlock(renderBlock), inputBlock(inputBlock), inputIndices(inputIndices) {
    }

    ~RenderJob() {
        delete outputBuffer;
    }

    /// Number of inputs feeding this AU.
    int32_t inputCount() {
        return static_cast<int32_t>(inputIndices.size());
    }

    void render(AudioUnitRenderActionFlags* actionFlags, const AudioTimeStamp* timeStamp, AUAudioFrameCount frameCount, AudioBufferList* outputBufferList=nullptr) {
        AudioBufferList* out = outputBufferList ? outputBufferList : outputBuffer->abl;
        
        // AUs may change the output size, so reset it.
        out->mBuffers[0].mDataByteSize = frameCount * sizeof(float);
        out->mBuffers[1].mDataByteSize = frameCount * sizeof(float);

        // Do the actual DSP.

        AUAudioUnitStatus status = renderBlock(actionFlags, timeStamp, frameCount, 0, out);

        // Propagate errors.
        if (status != noErr) {
            switch (status) {
                case kAudioUnitErr_NoConnection:
//                    std::cout << "got kAudioUnitErr_NoConnection" << std::endl;
                    break;
                case kAudioUnitErr_TooManyFramesToProcess:
//                    std::cout << "got kAudioUnitErr_TooManyFramesToProcess" << std::endl;
                    break;
//                case AVAudioEngineManualRenderingError::notRunning:
////                    std::cout << "got AVAudioEngineManualRenderingErrorNotRunning" << std::endl;
//                    break;
                case kAudio_ParamError:
//                    std::cout << "got kAudio_ParamError" << std::endl;
                    break;
                default:
//                    std::cout << "unknown rendering error " << status << std::endl;
            }
        }

        // Indicate that we're done writing to the output.
        outputBuffer->endWriting();
    }
};

} // namespace AudioKit


