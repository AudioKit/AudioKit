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
    sp_data *_sp = nullptr;
public:

    void init(int _channels, double _sampleRate) override {
        AKDSPBase::init(_channels, _sampleRate);
        sp_create(&_sp);
        _sp->sr = _sampleRate;
        _sp->nchan = _channels;
    }

    ~AKSoundpipeDSPBase() {
        //printf("~AKSoundpipeKernel(), &sp is %p\n", (void *)sp);
        // releasing the memory in the destructor only
        sp_destroy(&_sp);
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
            for (int channel = 0; channel <  _nChannels; ++channel) {
                float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    processSample(channel, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

};

#endif
