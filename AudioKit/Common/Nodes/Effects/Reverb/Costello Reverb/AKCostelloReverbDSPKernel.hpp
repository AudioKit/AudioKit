//
//  AKCostelloReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCostelloReverbDSPKernel_hpp
#define AKCostelloReverbDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    feedbackAddress = 0,
    cutoffFrequencyAddress = 1
};

class AKCostelloReverbDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKCostelloReverbDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
        revsc->feedback = 0.6;
        revsc->lpfreq = 4000;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_revsc_destroy(&revsc);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setFeedback(float feedback) {
        feedback = feedback;
        feedbackRamper.setImmediate(feedback);
    }

    void setCutoffFrequency(float lpfreq) {
        cutoffFrequency = lpfreq;
        cutoffFrequencyRamper.setImmediate(lpfreq);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, (float)0.0, (float)1.0));
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, (float)12.0, (float)20000.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case feedbackAddress:
                return feedbackRamper.getUIValue();

            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
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

            feedback = feedbackRamper.getAndStep();
            revsc->feedback = (float)feedback;
            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            revsc->lpfreq = (float)cutoffFrequency;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            
            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            sp_revsc_compute(sp, revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);

        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_revsc *revsc;

    float feedback = 0.6;
    float cutoffFrequency = 4000;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper feedbackRamper = 0.6;
    ParameterRamper cutoffFrequencyRamper = 4000;
};

#endif /* AKCostelloReverbDSPKernel_hpp */
