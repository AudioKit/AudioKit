//
//  AKThreePoleLowpassFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKThreePoleLowpassFilterDSPKernel_hpp
#define AKThreePoleLowpassFilterDSPKernel_hpp

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

class AKThreePoleLowpassFilterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKThreePoleLowpassFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_lpf18_create(&lpf18);
        sp_lpf18_init(sp, lpf18);
        lpf18->dist = 0.5;
        lpf18->cutoff = 1500;
        lpf18->res = 0.5;
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
    }

    void setDistortion(float dist) {
        distortion = dist;
        distortionRamper.setImmediate(dist);
    }

    void setCutoffFrequency(float cutoff) {
        cutoffFrequency = cutoff;
        cutoffFrequencyRamper.setImmediate(cutoff);
    }

    void setResonance(float res) {
        resonance = res;
        resonanceRamper.setImmediate(res);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case distortionAddress:
                distortionRamper.setUIValue(clamp(value, (float)0.0, (float)2.0));
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, (float)12.0, (float)20000.0));
                break;

            case resonanceAddress:
                resonanceRamper.setUIValue(clamp(value, (float)0.0, (float)2.0));
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
                distortionRamper.startRamp(clamp(value, (float)0.0, (float)2.0), duration);
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case resonanceAddress:
                resonanceRamper.startRamp(clamp(value, (float)0.0, (float)2.0), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            distortion = distortionRamper.getAndStep();
            lpf18->dist = (float)distortion;
            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            lpf18->cutoff = (float)cutoffFrequency;
            resonance = resonanceRamper.getAndStep();
            lpf18->res = (float)resonance;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_lpf18_compute(sp, lpf18, in, out);
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

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

#endif /* AKThreePoleLowpassFilterDSPKernel_hpp */
