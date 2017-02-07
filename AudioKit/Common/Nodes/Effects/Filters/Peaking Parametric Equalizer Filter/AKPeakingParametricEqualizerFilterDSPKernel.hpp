//
//  AKPeakingParametricEqualizerFilterDSPKernel.hpp
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
    gainAddress = 1,
    qAddress = 2
};

class AKPeakingParametricEqualizerFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKPeakingParametricEqualizerFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_pareq_create(&pareq0);
        sp_pareq_create(&pareq1);
        sp_pareq_init(sp, pareq0);
        sp_pareq_init(sp, pareq1);
        pareq0->fc = 1000;
        pareq1->fc = 1000;
        pareq0->v = 1.0;
        pareq1->v = 1.0;
        pareq0->q = 0.707;
        pareq1->q = 0.707;
        pareq0->mode = 0;
        pareq1->mode = 0;

        centerFrequencyRamper.init();
        gainRamper.init();
        qRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_pareq_destroy(&pareq0);
        sp_pareq_destroy(&pareq1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        centerFrequencyRamper.reset();
        gainRamper.reset();
        qRamper.reset();
    }

    void setCenterFrequency(float value) {
        centerFrequency = clamp(value, 12.0f, 20000.0f);
        centerFrequencyRamper.setImmediate(centerFrequency);
    }

    void setGain(float value) {
        gain = clamp(value, 0.0f, 10.0f);
        gainRamper.setImmediate(gain);
    }

    void setQ(float value) {
        q = clamp(value, 0.0f, 2.0f);
        qRamper.setImmediate(q);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case gainAddress:
                gainRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case qAddress:
                qRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case gainAddress:
                return gainRamper.getUIValue();

            case qAddress:
                return qRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case gainAddress:
                gainRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case qAddress:
                qRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            centerFrequency = centerFrequencyRamper.getAndStep();
            pareq0->fc = (float)centerFrequency;
            pareq1->fc = (float)centerFrequency;
            gain = gainRamper.getAndStep();
            pareq0->v = (float)gain;
            pareq1->v = (float)gain;
            q = qRamper.getAndStep();
            pareq0->q = (float)q;
            pareq1->q = (float)q;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_pareq_compute(sp, pareq0, in, out);
                    } else {
                        sp_pareq_compute(sp, pareq1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_pareq *pareq0;
    sp_pareq *pareq1;

    float centerFrequency = 1000;
    float gain = 1.0;
    float q = 0.707;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 1000;
    ParameterRamper gainRamper = 1.0;
    ParameterRamper qRamper = 0.707;
};
