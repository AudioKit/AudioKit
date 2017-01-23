//
//  AKCombFilterReverbDSPKernel.hpp
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

enum {
    reverbDurationAddress = 0
};

class AKCombFilterReverbDSPKernel : public AKSporthKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKCombFilterReverbDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);
        sp_comb_create(&comb);
        sp_comb_init(sp, comb, internalLoopDuration);
        comb->revtime = 1.0;

        reverbDurationRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_comb_destroy(&comb);
        AKSporthKernel::destroy();
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
            comb->revtime = (float)reverbDuration;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    sp_comb_compute(sp, comb, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_comb *comb;

    float reverbDuration = 1.0;
    float internalLoopDuration = 0.1;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper reverbDurationRamper = 1.0;
};

