//
//  AKThreePoleLowpassFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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

class AKThreePoleLowpassFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKThreePoleLowpassFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_lpf18_create(&lpf180);
        sp_lpf18_create(&lpf181);
        sp_lpf18_init(sp, lpf180);
        sp_lpf18_init(sp, lpf181);
        lpf180->dist = 0.5;
        lpf181->dist = 0.5;
        lpf180->cutoff = 1500;
        lpf181->cutoff = 1500;
        lpf180->res = 0.5;
        lpf181->res = 0.5;

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
        sp_lpf18_destroy(&lpf180);
        sp_lpf18_destroy(&lpf181);
        AKSoundpipeKernel::destroy();
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
            lpf180->dist = (float)distortion;
            lpf181->dist = (float)distortion;
            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            lpf180->cutoff = (float)cutoffFrequency;
            lpf181->cutoff = (float)cutoffFrequency;
            resonance = resonanceRamper.getAndStep();
            lpf180->res = (float)resonance;
            lpf181->res = (float)resonance;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_lpf18_compute(sp, lpf180, in, out);
                    } else {
                        sp_lpf18_compute(sp, lpf181, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_lpf18 *lpf180;
    sp_lpf18 *lpf181;

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
