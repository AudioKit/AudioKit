//
//  AKSoundpipeDSPBase.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKDSPBase.hpp"
#import "DSPKernel.hpp" // for the clamp
#ifndef __cplusplus

#include "soundpipe.h"
#include "vocwrapper.h"

#else

extern "C" {
#include "soundpipe.h"
#include "vocwrapper.h"
}

class AKSoundpipeDSPBase: public AKDSPBase {
protected:
    sp_data *sp = nullptr;
public:

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channelCount;
    }

    ~AKSoundpipeDSPBase() {
        //printf("~AKSoundpipeKernel(), &sp is %p\n", (void *)sp);
        // releasing the memory in the destructor only
        sp_destroy(&sp);
    }

    // Is this needed? Ramping should be rethought
    virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {}

    virtual void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {}
    virtual AUValue getParameter(AUParameterAddress address) override { return 0.0f; }

    virtual void processSample(int channel, float *in, float *out) {
        *out = *in;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            for (int channel = 0; channel <  channelCount; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

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
