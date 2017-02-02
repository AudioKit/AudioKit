//
//  AKChowningReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}


class AKChowningReverbDSPKernel : public AKSporthKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKChowningReverbDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);

        sp_jcrev_create(&jcrev0);
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_create(&jcrev1);
        sp_jcrev_init(sp, jcrev1);
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_jcrev_destroy(&jcrev0);
        sp_jcrev_destroy(&jcrev1);
        AKSporthKernel::destroy();
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    if (channel==0) {
                        sp_jcrev_compute(sp, jcrev0, in, out);
                    } else {
                        sp_jcrev_compute(sp, jcrev1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;

public:
    bool started = true;
    bool resetted = true;
};

