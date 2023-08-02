// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include <vector>
#include <functional>
#include <atomic>
#include <memory>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include "SynchronizedAudioBufferList.h"

typedef int RenderJobIndex;

namespace AudioKit {

class RenderJob {
private:
    /// Buffer we're writing to, unless overridden by buffer passed to render.
    std::shared_ptr<SynrchonizedAudioBufferList2> outputBuffer;
    
    /// Block called to render.
    AURenderBlock renderBlock;

    /// Input block passed to the renderBlock. We don't chain AUs recursively.
    AURenderPullInputBlock inputBlock;

    /// Indices of jobs feeding this one
    std::vector<int> inputIndices;

public:
    
    /// Indices of jobs that this one feeds.
    std::vector<int> outputIndices;
    
    RenderJob(std::shared_ptr<SynrchonizedAudioBufferList2> outputBuffer,
              AURenderBlock renderBlock,
              AURenderPullInputBlock inputBlock,
              std::vector<int> inputIndices)
    : outputBuffer(outputBuffer), renderBlock(renderBlock), inputBlock(inputBlock), inputIndices(inputIndices) {
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
        AUAudioUnitStatus status = renderBlock(actionFlags, timeStamp, frameCount, 0, out, inputBlock);

        // Propagate errors.
        if (status != noErr) {
            switch (status) {
                case kAudioUnitErr_NoConnection:
                    printf("got kAudioUnitErr_NoConnection\n");
                    break;
                case kAudioUnitErr_TooManyFramesToProcess:
                    printf("got kAudioUnitErr_TooManyFramesToProcess\n");
                    break;
                case AVAudioEngineManualRenderingErrorNotRunning:
                    printf("got AVAudioEngineManualRenderingErrorNotRunning\n");
                    break;
                case kAudio_ParamError:
                    printf("got kAudio_ParamError\n");
                    break;
                default:
                    printf("unkown rendering error\n");
                    break;
            }
        }

        // Indicate that we're done writing to the output.
        outputBuffer->endWriting();
    }
};

} // namespace AudioKit


