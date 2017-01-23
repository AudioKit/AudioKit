//
//  AKToneFilterDSPKernel.hpp
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
    halfPowerPointAddress = 0
};

class AKToneFilterDSPKernel : public AKSporthKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKToneFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);

        sp_tone_create(&tone);
        sp_tone_init(sp, tone);
        tone->hp = 1000.0;

        halfPowerPointRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_tone_destroy(&tone);
        AKSporthKernel::destroy();
    }

    void reset() {
        resetted = true;
        halfPowerPointRamper.reset();
    }

    void setHalfPowerPoint(float value) {
        halfPowerPoint = clamp(value, 12.0f, 20000.0f);
        halfPowerPointRamper.setImmediate(halfPowerPoint);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case halfPowerPointAddress:
                halfPowerPointRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case halfPowerPointAddress:
                return halfPowerPointRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case halfPowerPointAddress:
                halfPowerPointRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            halfPowerPoint = halfPowerPointRamper.getAndStep();
            tone->hp = (float)halfPowerPoint;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_tone_compute(sp, tone, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_tone *tone;

    float halfPowerPoint = 1000.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper halfPowerPointRamper = 1000.0;
};

