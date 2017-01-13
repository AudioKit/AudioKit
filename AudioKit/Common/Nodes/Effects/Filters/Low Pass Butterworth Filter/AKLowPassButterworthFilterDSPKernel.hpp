//
//  AKLowPassButterworthFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//
#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    cutoffFrequencyAddress = 0
};

class AKLowPassButterworthFilterDSPKernel : public AKSporthKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKLowPassButterworthFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);

        sp_butlp_create(&butlp);
        sp_butlp_init(sp, butlp);
        butlp->freq = 1000.0;

        cutoffFrequencyRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_butlp_destroy(&butlp);
        AKSporthKernel::destroy();
    }

    void reset() {
        resetted = true;
        cutoffFrequencyRamper.reset();
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 12.0f, 20000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            butlp->freq = (float)cutoffFrequency;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_butlp_compute(sp, butlp, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:
    sp_butlp *butlp;

    float cutoffFrequency = 1000.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper cutoffFrequencyRamper = 1000.0;
};

