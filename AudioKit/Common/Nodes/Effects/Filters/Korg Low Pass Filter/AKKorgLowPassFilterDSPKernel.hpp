//
//  AKKorgLowPassFilterDSPKernel.hpp
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
    cutoffFrequencyAddress = 0,
    resonanceAddress = 1,
    saturationAddress = 2
};

class AKKorgLowPassFilterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKKorgLowPassFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_wpkorg35_create(&wpkorg35);
        sp_wpkorg35_init(sp, wpkorg35);
        wpkorg35->cutoff = 1000.0;
        wpkorg35->res = 1.0;
        wpkorg35->saturation = 0.0;

        cutoffFrequencyRamper.init();
        resonanceRamper.init();
        saturationRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_wpkorg35_destroy(&wpkorg35);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        cutoffFrequencyRamper.reset();
        resonanceRamper.reset();
        saturationRamper.reset();
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 0.0f, 22050.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }

    void setResonance(float value) {
        resonance = clamp(value, 0.0f, 2.0f);
        resonanceRamper.setImmediate(resonance);
    }

    void setSaturation(float value) {
        saturation = clamp(value, 0.0f, 10.0f);
        saturationRamper.setImmediate(saturation);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 0.0f, 22050.0f));
                break;

            case resonanceAddress:
                resonanceRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

            case saturationAddress:
                saturationRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            case resonanceAddress:
                return resonanceRamper.getUIValue();

            case saturationAddress:
                return saturationRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 0.0f, 22050.0f), duration);
                break;

            case resonanceAddress:
                resonanceRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

            case saturationAddress:
                saturationRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            wpkorg35->cutoff = (float)cutoffFrequency - 0.0001;
            resonance = resonanceRamper.getAndStep();
            wpkorg35->res = (float)resonance;
            saturation = saturationRamper.getAndStep();
            wpkorg35->saturation = (float)saturation;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_wpkorg35_compute(sp, wpkorg35, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_wpkorg35 *wpkorg35;

    float cutoffFrequency = 1000.0;
    float resonance = 1.0;
    float saturation = 0.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper cutoffFrequencyRamper = 1000.0;
    ParameterRamper resonanceRamper = 1.0;
    ParameterRamper saturationRamper = 0.0;
};

