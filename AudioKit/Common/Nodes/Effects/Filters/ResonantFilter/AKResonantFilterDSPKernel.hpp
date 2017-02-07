//
//  AKResonantFilterDSPKernel.hpp
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
    bandwidthAddress = 1
};

class AKResonantFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKResonantFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_reson_create(&reson0);
        sp_reson_create(&reson1);
        sp_reson_init(sp, reson0);
        sp_reson_init(sp, reson1);
        reson0->freq = 4000.0;
        reson1->freq = 4000.0;
        reson0->bw = 1000.0;
        reson1->bw = 1000.0;

        frequencyRamper.init();
        bandwidthRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_reson_destroy(&reson0);
        sp_reson_destroy(&reson1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        frequencyRamper.reset();
        bandwidthRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, 100.0f, 20000.0f);
        frequencyRamper.setImmediate(frequency);
    }

    void setBandwidth(float value) {
        bandwidth = clamp(value, 0.0f, 10000.0f);
        bandwidthRamper.setImmediate(bandwidth);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 100.0f, 20000.0f));
                break;

            case bandwidthAddress:
                bandwidthRamper.setUIValue(clamp(value, 0.0f, 10000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case bandwidthAddress:
                return bandwidthRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, 100.0f, 20000.0f), duration);
                break;

            case bandwidthAddress:
                bandwidthRamper.startRamp(clamp(value, 0.0f, 10000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = frequencyRamper.getAndStep();
            reson0->freq = (float)frequency;
            reson1->freq = (float)frequency;
            bandwidth = bandwidthRamper.getAndStep();
            reson0->bw = (float)bandwidth;
            reson1->bw = (float)bandwidth;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_reson_compute(sp, reson0, in, out);
                    } else {
                        sp_reson_compute(sp, reson1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_reson *reson0;
    sp_reson *reson1;

    float frequency = 4000.0;
    float bandwidth = 1000.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper = 4000.0;
    ParameterRamper bandwidthRamper = 1000.0;
};
