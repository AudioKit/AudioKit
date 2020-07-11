// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKStereoDelayDSP.hpp"
#include "StereoDelay.hpp"
#import "ParameterRamper.hpp"

#include "AKDSPBase.hpp"

class AKStereoDelayDSP : public AKDSPBase {
private:
    AudioKitCore::StereoDelay delay;
    float timeUpperBound = 2.f;
    ParameterRamper timeRamp;
    ParameterRamper feedbackRamp;
    ParameterRamper dryWetMixRamp;

public:
    AKStereoDelayDSP() {
        parameters[AKStereoDelayParameterTime] = &timeRamp;
        parameters[AKStereoDelayParameterFeedback] = &feedbackRamp;
        parameters[AKStereoDelayParameterDryWetMix] = &dryWetMixRamp;

        bCanProcessInPlace = true;
    }

    void setParameter(AUParameterAddress address, AUValue value, bool immediate) {
        if (address == AKStereoDelayParameterPingPong) {
            delay.setPingPongMode(value > 0.5f);
        }
        else {
            AKDSPBase::setParameter(address, value, immediate);
        }
    }

    float getParameter(uint64_t address) {
        if (address == AKStereoDelayParameterPingPong) {
            return delay.getPingPongMode() ? 1.0f : 0.0f;
        }
        else {
            return AKDSPBase::getParameter(address);
        }
    }

    void init(int channelCount, double sampleRate) {
        AKDSPBase::init(channelCount, sampleRate);
        // TODO add something to handle 1 vs 2 channels
        delay.init(sampleRate, timeUpperBound * 1000.0);
    }

    void deinit() {
        AKDSPBase::deinit();
        delay.deinit();
    }

    void reset() {
        AKDSPBase::reset();
        delay.clear();
    }

#define CHUNKSIZE 8     // defines ramp interval

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
    {
        const float *inBuffers[2];
        float *outBuffers[2];
        inBuffers[0]  = (const float *)inputBufferLists[0]->mBuffers[0].mData  + bufferOffset;
        inBuffers[1]  = (const float *)inputBufferLists[0]->mBuffers[1].mData  + bufferOffset;
        outBuffers[0] = (float *)outputBufferLists[0]->mBuffers[0].mData + bufferOffset;
        outBuffers[1] = (float *)outputBufferLists[0]->mBuffers[1].mData + bufferOffset;
        //unsigned inChannelCount = inputBufferLists[0]->mNumberBuffers;
        //unsigned outChannelCount = outputBufferLists[0]->mNumberBuffers;

        if (!isStarted)
        {
            // effect bypassed: just copy input to output
            memcpy(outBuffers[0], inBuffers[0], frameCount * sizeof(float));
            memcpy(outBuffers[1], inBuffers[1], frameCount * sizeof(float));
            return;
        }

        // process in chunks of maximum length CHUNKSIZE
        for (int frameIndex = 0; frameIndex < frameCount; frameIndex += CHUNKSIZE)
        {
            int chunkSize = frameCount - frameIndex;
            if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

            // ramp parameters
            timeRamp.stepBy(chunkSize);
            feedbackRamp.stepBy(chunkSize);
            dryWetMixRamp.stepBy(chunkSize);

            // apply changes
            delay.setDelayMs(1000.0 * timeRamp.get());
            delay.setFeedback(feedbackRamp.get());
            delay.setDryWetMix(dryWetMixRamp.get());

            // process
            delay.render(chunkSize, inBuffers, outBuffers);

            // advance pointers
            inBuffers[0] += chunkSize;
            inBuffers[1] += chunkSize;
            outBuffers[0] += chunkSize;
            outBuffers[1] += chunkSize;
        }
    }
};

extern "C" AKDSPRef createStereoDelayDSP() {
    return new AKStereoDelayDSP();
}

