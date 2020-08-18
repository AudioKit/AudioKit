// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "AudioKitCore/Modulated Delay/StereoDelay.hpp"

enum AKStereoDelayParameter : AUParameterAddress {
    AKStereoDelayParameterTime,
    AKStereoDelayParameterFeedback,
    AKStereoDelayParameterDryWetMix,
    AKStereoDelayParameterPingPong,
};

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

    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        if (address == AKStereoDelayParameterPingPong) {
            delay.setPingPongMode(value > 0.5f);
        }
        else {
            AKDSPBase::setParameter(address, value, immediate);
        }
    }

    float getParameter(uint64_t address) override {
        if (address == AKStereoDelayParameterPingPong) {
            return delay.getPingPongMode() ? 1.0f : 0.0f;
        }
        else {
            return AKDSPBase::getParameter(address);
        }
    }

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);
        // TODO add something to handle 1 vs 2 channels
        delay.init(sampleRate, timeUpperBound * 1000.0);
    }

    void deinit() override {
        AKDSPBase::deinit();
        delay.deinit();
    }

    void reset() override {
        AKDSPBase::reset();
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

AK_REGISTER_DSP(AKStereoDelayDSP)
AK_REGISTER_PARAMETER(AKStereoDelayParameterTime)
AK_REGISTER_PARAMETER(AKStereoDelayParameterFeedback)
AK_REGISTER_PARAMETER(AKStereoDelayParameterDryWetMix)
AK_REGISTER_PARAMETER(AKStereoDelayParameterPingPong)
