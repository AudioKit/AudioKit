// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "TapNode.h"

#include "DSPBase.h"

struct TapNodeDSP : DSPBase {

    TPCircularBuffer leftBuffer;
    TPCircularBuffer rightBuffer;

    TapNodeDSP() {
        TPCircularBufferInit(&leftBuffer, 4096 * sizeof(float));
        TPCircularBufferInit(&rightBuffer, 4096 * sizeof(float));
        bCanProcessInPlace = true;
    }

    ~TapNodeDSP() {
        TPCircularBufferCleanup(&leftBuffer);
        TPCircularBufferCleanup(&rightBuffer);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in   = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out  = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = *in;
            }
        }
        TPCircularBufferProduceBytes(&leftBuffer,  inputBufferLists[0]->mBuffers[0].mData, frameCount * sizeof(float));
        TPCircularBufferProduceBytes(&rightBuffer, inputBufferLists[0]->mBuffers[1].mData, frameCount * sizeof(float));
    }
};

AK_REGISTER_DSP(TapNodeDSP)

AK_API TPCircularBuffer* akTapNodeGetLeftBuffer(DSPRef dsp) {
    return &static_cast<TapNodeDSP*>(dsp)->leftBuffer;
}
AK_API TPCircularBuffer* akTapNodeGetRightBuffer(DSPRef dsp) {
    return &static_cast<TapNodeDSP*>(dsp)->rightBuffer;
}
