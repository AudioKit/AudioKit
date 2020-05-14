// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKDSPBase.hpp"
#import "DSPKernel.hpp" // for the clamp
#ifndef __cplusplus

#include "soundpipe.h"
#include "soundpipeextension.h"
#include "vocwrapper.h"

#else

extern "C" {
#include "soundpipe.h"
#include "soundpipeextension.h"
#include "vocwrapper.h"
}

class AKSoundpipeDSPBase: public AKDSPBase {
protected:
    sp_data *sp = nullptr;
public:
    AKSoundpipeDSPBase() {
        bCanProcessInPlace = true;
    }
    
    virtual void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channelCount;
    }

    virtual void deinit() override {
        AKDSPBase::deinit();
        sp_destroy(&sp);
    }

    virtual void processSample(int channel, float *in, float *out) {
        *out = *in;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            for (int channel = 0; channel <  channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    processSample(channel, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

};

#endif
