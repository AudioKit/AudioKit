//
//  AKThreePoleLowpassFilterDSPKernel.hpp
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
    distortionAddress = 0,
    cutoffFrequencyAddress = 1,
    resonanceAddress = 2
};

class AKThreePoleLowpassFilterDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKThreePoleLowpassFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKDSPKernel::init(channelCount, inSampleRate);
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_lpf18_create(&lpf18);
        sp_lpf18_init(sp, lpf18);
        lpf18->dist = 0.5;
        lpf18->cutoff = 1500;
        lpf18->res = 0.5;

        distortionRamper.init();
        cutoffFrequencyRamper.init();
        resonanceRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_lpf18_destroy(&lpf18);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        distortionRamper.reset();
        cutoffFrequencyRamper.reset();
        resonanceRamper.reset();
    }

    void setDistortion(float value) {
        distortion = clamp(value, 0.0f, 2.0f);
        distortionRamper.setImmediate(distortion);
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 12.0f, 20000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }

    void setResonance(float value) {
        resonance = clamp(value, 0.0f, 2.0f);
        resonanceRamper.setImmediate(resonance);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case distortionAddress:
                distortionRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case resonanceAddress:
                resonanceRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case distortionAddress:
                return distortionRamper.getUIValue();

            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            case resonanceAddress:
                return resonanceRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case distortionAddress:
                distortionRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case resonanceAddress:
                resonanceRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            distortion = distortionRamper.getAndStep();
            lpf18->dist = (float)distortion;
            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            lpf18->cutoff = (float)cutoffFrequency;
            resonance = resonanceRamper.getAndStep();
            lpf18->res = (float)resonance;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_lpf18_compute(sp, lpf18, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_data *sp;
    sp_lpf18 *lpf18;

    float distortion = 0.5;
    float cutoffFrequency = 1500;
    float resonance = 0.5;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper distortionRamper = 0.5;
    ParameterRamper cutoffFrequencyRamper = 1500;
    ParameterRamper resonanceRamper = 0.5;
};

