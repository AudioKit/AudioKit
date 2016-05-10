//
//  AKPinkNoiseDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPinkNoiseDSPKernel_hpp
#define AKPinkNoiseDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    amplitudeAddress = 0
};

class AKPinkNoiseDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKPinkNoiseDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_pinknoise_create(&pinknoise);
        sp_pinknoise_init(sp, pinknoise);
        *pinknoise->amp = 1;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_pinknoise_destroy(&pinknoise);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.setImmediate(amp);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
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
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

        }
    }

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            amplitude = amplitudeRamper.getAndStep();
            *pinknoise->amp = (float)amplitude;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_pinknoise_compute(sp, pinknoise, nil, &temp);
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

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_pinknoise *pinknoise;

    float amplitude = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper amplitudeRamper = 1;
};

#endif /* AKPinkNoiseDSPKernel_hpp */
