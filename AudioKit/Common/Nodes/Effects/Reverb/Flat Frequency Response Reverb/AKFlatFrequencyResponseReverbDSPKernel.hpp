//
//  AKFlatFrequencyResponseReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    reverbDurationAddress = 0
};

class AKFlatFrequencyResponseReverbDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKFlatFrequencyResponseReverbDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
        sp_allpass_create(&allpass0);
        sp_allpass_create(&allpass1);
        sp_allpass_init(sp, allpass0, internalLoopDuration);
        sp_allpass_init(sp, allpass1, internalLoopDuration);
        allpass0->revtime = 0.5;
        allpass1->revtime = 0.5;

        reverbDurationRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_allpass_destroy(&allpass0);
        sp_allpass_destroy(&allpass1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        reverbDurationRamper.reset();
    }

    void setReverbDuration(float value) {
        reverbDuration = clamp(value, 0.0f, 10.0f);
        reverbDurationRamper.setImmediate(reverbDuration);
    }

    void setLoopDuration(float duration) {
        internalLoopDuration = duration;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case reverbDurationAddress:
                reverbDurationRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case reverbDurationAddress:
                return reverbDurationRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case reverbDurationAddress:
                reverbDurationRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            reverbDuration = reverbDurationRamper.getAndStep();
            allpass0->revtime = (float)reverbDuration;
            allpass1->revtime = (float)reverbDuration;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel==0) {
                        sp_allpass_compute(sp, allpass0, in, out);
                    } else {
                        sp_allpass_compute(sp, allpass1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_allpass *allpass0;
    sp_allpass *allpass1;

    float reverbDuration = 0.5;
    float internalLoopDuration = 0.1;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper reverbDurationRamper = 0.5;
};
