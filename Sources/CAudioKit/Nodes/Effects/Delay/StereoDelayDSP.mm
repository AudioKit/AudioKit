// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "AudioKitCore/Modulated Delay/StereoDelay.h"

enum StereoDelayParameter : AUParameterAddress {
    StereoDelayParameterTime,
    StereoDelayParameterFeedback,
    StereoDelayParameterDryWetMix,
    StereoDelayParameterPingPong,
};

class StereoDelayDSP : public DSPBase {
private:
    AudioKitCore::StereoDelay delay;
    float timeUpperBound = 2.f;
    ParameterRamper timeRamp;
    ParameterRamper feedbackRamp;
    ParameterRamper dryWetMixRamp;

public:
    StereoDelayDSP() : DSPBase(1, true) {
        parameters[StereoDelayParameterTime] = &timeRamp;
        parameters[StereoDelayParameterFeedback] = &feedbackRamp;
        parameters[StereoDelayParameterDryWetMix] = &dryWetMixRamp;
    }

    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        if (address == StereoDelayParameterPingPong) {
            delay.setPingPongMode(value > 0.5f);
        }
        else {
            DSPBase::setParameter(address, value, immediate);
        }
    }

    float getParameter(uint64_t address) override {
        if (address == StereoDelayParameterPingPong) {
            return delay.getPingPongMode() ? 1.0f : 0.0f;
        }
        else {
            return DSPBase::getParameter(address);
        }
    }

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);
        delay.init(sampleRate, timeUpperBound * 1000.0);
    }

    void deinit() override {
        DSPBase::deinit();
        delay.deinit();
    }

    void reset() override {
        DSPBase::reset();
        delay.clear();
    }

#define CHUNKSIZE 8     // defines ramp interval

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        const float *inBuffers[2];
        float *outBuffers[2];
        inBuffers[0]  = (const float *)inputBufferLists[0]->mBuffers[0].mData  + bufferOffset;
        inBuffers[1]  = (const float *)inputBufferLists[0]->mBuffers[1].mData  + bufferOffset;
        outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + bufferOffset;
        outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + bufferOffset;
        //unsigned inChannelCount = inputBufferLists[0]->mNumberBuffers;
        //unsigned outChannelCount = outputBufferList->mNumberBuffers;

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

AK_REGISTER_DSP(StereoDelayDSP, "sdly")
AK_REGISTER_PARAMETER(StereoDelayParameterTime)
AK_REGISTER_PARAMETER(StereoDelayParameterFeedback)
AK_REGISTER_PARAMETER(StereoDelayParameterDryWetMix)
AK_REGISTER_PARAMETER(StereoDelayParameterPingPong)
