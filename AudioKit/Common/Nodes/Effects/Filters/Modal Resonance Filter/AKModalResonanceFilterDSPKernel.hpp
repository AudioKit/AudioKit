//
//  AKModalResonanceFilterDSPKernel.hpp
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
    frequencyAddress = 0,
    qualityFactorAddress = 1
};

class AKModalResonanceFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKModalResonanceFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_mode_create(&mode0);
        sp_mode_create(&mode1);
        sp_mode_init(sp, mode0);
        sp_mode_init(sp, mode1);
        mode0->freq = 500.0;
        mode1->freq = 500.0;
        mode0->q = 50.0;
        mode1->q = 50.0;

        frequencyRamper.init();
        qualityFactorRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_mode_destroy(&mode0);
        sp_mode_destroy(&mode1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        frequencyRamper.reset();
        qualityFactorRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, 12.0f, 20000.0f);
        frequencyRamper.setImmediate(frequency);
    }

    void setQualityFactor(float value) {
        qualityFactor = clamp(value, 0.0f, 100.0f);
        qualityFactorRamper.setImmediate(qualityFactor);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case qualityFactorAddress:
                qualityFactorRamper.setUIValue(clamp(value, 0.0f, 100.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case qualityFactorAddress:
                return qualityFactorRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case qualityFactorAddress:
                qualityFactorRamper.startRamp(clamp(value, 0.0f, 100.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = frequencyRamper.getAndStep();
            mode0->freq = (float)frequency;
            mode1->freq = (float)frequency;
            qualityFactor = qualityFactorRamper.getAndStep();
            mode0->q = (float)qualityFactor;
            mode1->q = (float)qualityFactor;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_mode_compute(sp, mode0, in, out);
                    } else {
                        sp_mode_compute(sp, mode1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_mode *mode0;
    sp_mode *mode1;

    float frequency = 500.0;
    float qualityFactor = 50.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper = 500.0;
    ParameterRamper qualityFactorRamper = 50.0;
};
