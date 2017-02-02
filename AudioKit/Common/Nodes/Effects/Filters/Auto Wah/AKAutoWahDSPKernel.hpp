//
//  AKAutoWahDSPKernel.hpp
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
    wahAddress = 0,
    mixAddress = 1,
    amplitudeAddress = 2
};

class AKAutoWahDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKAutoWahDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_autowah_create(&autowah0);
        sp_autowah_init(sp, autowah0);
        *autowah0->wah = 0.0;
        *autowah0->mix = 1.0;
        *autowah0->level = 0.1;

        sp_autowah_create(&autowah1);
        sp_autowah_init(sp, autowah1);
        *autowah1->wah = 0.0;
        *autowah1->mix = 1.0;
        *autowah1->level = 0.1;

        wahRamper.init();
        mixRamper.init();
        amplitudeRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_autowah_destroy(&autowah0);
        sp_autowah_destroy(&autowah1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        wahRamper.reset();
        mixRamper.reset();
        amplitudeRamper.reset();
    }

    void setWah(float value) {
        wah = clamp(value, 0.0f, 1.0f);
        wahRamper.setImmediate(wah);
    }

    void setMix(float value) {
        mix = clamp(value, 0.0f, 1.0f);
        mixRamper.setImmediate(mix);
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 1.0f);
        amplitudeRamper.setImmediate(amplitude);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case wahAddress:
                wahRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case mixAddress:
                mixRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case wahAddress:
                return wahRamper.getUIValue();

            case mixAddress:
                return mixRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case wahAddress:
                wahRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case mixAddress:
                mixRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            wah = wahRamper.getAndStep();
            *autowah0->wah = (float)wah;
            *autowah1->wah = (float)wah;
            mix = mixRamper.getAndStep();
            *autowah0->mix = (float)mix * 100.0;
            *autowah1->mix = (float)mix * 100.0;
            amplitude = amplitudeRamper.getAndStep();
            *autowah0->level = (float)amplitude;
            *autowah1->level = (float)amplitude;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_autowah_compute(sp, autowah0, in, out);
                    } else {
                        sp_autowah_compute(sp, autowah1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_autowah *autowah0;
    sp_autowah *autowah1;

    float wah = 0.0;
    float mix = 1.0;
    float amplitude = 0.1;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper wahRamper = 0.0;
    ParameterRamper mixRamper = 1.0;
    ParameterRamper amplitudeRamper = 0.1;
};
