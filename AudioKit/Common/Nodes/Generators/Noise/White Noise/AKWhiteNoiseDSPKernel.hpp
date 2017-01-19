//
//  AKWhiteNoiseDSPKernel.hpp
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
    amplitudeAddress = 0
};

class AKWhiteNoiseDSPKernel : public AKSporthKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKWhiteNoiseDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);

        sp_noise_create(&noise);
        sp_noise_init(sp, noise);
        noise->amp = 1;

        amplitudeRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_noise_destroy(&noise);
        AKSporthKernel::destroy();
    }

    void reset() {
        resetted = true;
        amplitudeRamper.reset();
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 1.0f);
        amplitudeRamper.setImmediate(amplitude);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            amplitude = amplitudeRamper.getAndStep();
            noise->amp = (float)amplitude;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_noise_compute(sp, noise, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_noise *noise;

    float amplitude = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper amplitudeRamper = 1;
};


