//
//  AKBandPassButterworthFilterDSPKernel.hpp
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
    centerFrequencyAddress = 0,
    bandwidthAddress = 1
};

class AKBandPassButterworthFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKBandPassButterworthFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_butbp_create(&butbp0);
        sp_butbp_create(&butbp1);
        sp_butbp_init(sp, butbp0);
        sp_butbp_init(sp, butbp1);
        butbp0->freq = 2000.0;
        butbp1->freq = 2000.0;
        butbp0->bw = 100.0;
        butbp1->bw = 100.0;

        centerFrequencyRamper.init();
        bandwidthRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_butbp_destroy(&butbp0);
        sp_butbp_destroy(&butbp1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        centerFrequencyRamper.reset();
        bandwidthRamper.reset();
    }

    void setCenterFrequency(float value) {
        centerFrequency = clamp(value, 12.0f, 20000.0f);
        centerFrequencyRamper.setImmediate(centerFrequency);
    }

    void setBandwidth(float value) {
        bandwidth = clamp(value, 0.0f, 20000.0f);
        bandwidthRamper.setImmediate(bandwidth);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case bandwidthAddress:
                bandwidthRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case bandwidthAddress:
                return bandwidthRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case bandwidthAddress:
                bandwidthRamper.startRamp(clamp(value, 0.0f, 20000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            centerFrequency = centerFrequencyRamper.getAndStep();
            butbp0->freq = (float)centerFrequency;
            butbp1->freq = (float)centerFrequency;
            bandwidth = bandwidthRamper.getAndStep();
            butbp0->bw = (float)bandwidth;
            butbp1->bw = (float)bandwidth;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_butbp_compute(sp, butbp0, in, out);
                    } else {
                        sp_butbp_compute(sp, butbp1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_butbp *butbp0;
    sp_butbp *butbp1;

    float centerFrequency = 2000.0;
    float bandwidth = 100.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 2000.0;
    ParameterRamper bandwidthRamper = 100.0;
};
