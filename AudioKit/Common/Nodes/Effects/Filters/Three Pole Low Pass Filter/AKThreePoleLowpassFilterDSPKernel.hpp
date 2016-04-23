//
//  AKThreePoleLowpassFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKThreePoleLowpassFilterDSPKernel_hpp
#define AKThreePoleLowpassFilterDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    distortionAddress = 0,
    cutoffFrequencyAddress = 1,
    resonanceAddress = 2
};

class AKThreePoleLowpassFilterDSPKernel : public AKDSPKernel {
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
            double distortion = double(distortionRamper.getAndStep());
            double cutoffFrequency = double(cutoffFrequencyRamper.getAndStep());
            double resonance = double(resonanceRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            lpf18->dist = (float)distortion;
            lpf18->cutoff = (float)cutoffFrequency;
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

public:
    bool started = true;
    AKParameterRamper distortionRamper = 0.5;
    AKParameterRamper cutoffFrequencyRamper = 1500;
    AKParameterRamper resonanceRamper = 0.5;
};

#endif /* AKThreePoleLowpassFilterDSPKernel_hpp */
